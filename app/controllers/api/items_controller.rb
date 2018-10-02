class Api::ItemsController < Api::ApiController

  require "standard_file"

  def sync_manager
    if !@sync_manager
      @sync_manager = StandardFile::SyncManager.new(current_user)
    end
    @sync_manager
  end

  def sync
    options = {
      :sync_token => params[:sync_token],
      :cursor_token => params[:cursor_token],
      :limit => params[:limit]
    }
    is_demo = is_account_demo(current_user.email)

    save_items = is_demo ? [] : params[:items]
    results = sync_manager.sync(save_items, options)

    if is_demo == false
      post_to_extensions(params.to_unsafe_hash[:items])
    end

    render :json => results
  end

  def post_to_extensions(items)
    if !items || items.length == 0
      return
    end

    extensions = current_user.items.where(:content_type => "SF|Extension")
    extensions.each do |ext|
      content = ext.decoded_content
      if content && content["subtype"] == nil
        post_to_extension(content["url"], items)
      end
    end
  end

  def post_to_extension(url, items)
    if url && url.length > 0
      ExtensionJob.perform_later(url, items, user_manager.auth_params(current_user.email))
    end
  end

  # Writes all user data to backup extension.
  # This is called when a new extension is registered.
  def backup
    if is_account_demo(current_user.email)
      return
    end
    ext = current_user.items.find(params[:uuid])
    content = ext.decoded_content
    if content && content["subtype"] == nil
      items = current_user.items.to_a
      if items && items.length > 0
        post_to_extension(content["url"], items)
      end
    end
  end


  ##
  ## REST API
  ##

  def create
    if is_account_demo(current_user.email)
      render :json => {:item => params[:item]}
      return
    end
    item = current_user.items.new(params[:item].permit(*permitted_params))
    item.save
    render :json => {:item => item}
  end

  def destroy
    if is_account_demo(current_user.email)
      render :json => {}, :status => 204
      return
    end
    ids = params[:uuids] || [params[:uuid]]
    sync_manager.destroy_items(ids)
    render :json => {}, :status => 204
  end

  private

  def permitted_params
    [:content_type, :content, :auth_hash, :enc_item_key]
  end

end
