class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i(show edit update destroy like unlike)
  before_action :owned_post, only: %i(edit update destroy)

  def index
    @posts = Post.followed_users_or_owned_by(current_user)
                 .order(created_at: :desc)
                 .page(params[:page])
  end

  def browse
    @posts = Post.all.order(created_at: :desc).page(params[:page])
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to root_path, notice: t('posts.create.notice')
    else
      flash.now[:alert] = t('posts.create.alert')
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to root_path, notice: t('posts.update.notice')
    else
      flash.now[:alert] = t('posts.update.alert')
      render :edit
    end
  end

  def destroy
    if @post.destroy
      redirect_to root_path, notice: t('posts.destroy.notice')
    else
      flash.now[:alert] = t('posts.destroy.alert')
      render :edit
    end
  end

  def like
    if @post.liked_by current_user
      create_notification @post
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      end
    end
  end

  def unlike
    if @post.unliked_by current_user
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.js
      end
    end
  end

  private

  def post_params
    params.require(:post).permit(:image, :description)
  end

  def owned_post
    @post = current_user.posts.find_by(id: params[:id])
    if @post.nil?
      redirect_to root_path, alert: t('posts.owned_post.alert')
    end
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def create_notification(post)
    return if post.user.id == current_user.id
    Notification.create(user_id: post.user.id,
                        notified_by_id: current_user.id,
                        post_id: post.id,
                        identifier: post.id,
                        notice_type: 'like')
  end
end
