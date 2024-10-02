# Assets belongs to parent and author
# at any given time, one parent can only have one active 

# Imagine this file comes from a pull request from one of your peer.
# Comment / Challenge / Make everything as if it was a real PR.
#
# You can either create a private repo and create a real pull request OR add your comments directly in the code (on a gist).


class AssetsController < ApplicationController
  def index
    # this action is VERY slow, let's figure out why
    collection = []

    Asset.where(active: true).where('created_at > ?', 2.days.ago).order('id ASC').each do |asset|
      serialized = {
        title: asset.title,
        full_size: "#{asset.width}x#{asset.height}px",
        parent_id: asset.parent.id,
        author: asset.author.name
      }
      collection << serialized
    end

    render json: collection
  end

  def activate
    asset = Asset.find(params[:id])

    activate_asset(asset)

    redirect_to asset, notice: 'Asset activé'
  end

  def deactivate
    asset = Asset.find(params[:id])

    asset.update(active: false)
    AssetMailer.deactivated(asset).deliver_now

    redirect_to asset, notice: 'Asset desactivé'
  end

  def activate_asset
    asset.update(active: true)
    asset.parent.assets.each do |other_asset|
      next unless other_asset.active?
      next if other_asset == asset

      other_asset.update(active: false)
    end
    AssetMailer.activated(asset).deliver_now
  end
end
