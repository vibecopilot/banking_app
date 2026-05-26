module Api
  module V1
    class PortalsController < ApplicationController
      include UserExt

      before_action :api_user
      before_action :set_portal, only: [:sso_url]

      # ─────────────────────────────────────────────────────────────
      # GET /api/v1/portals
      # Returns portals this user has access to.
      # Frontend uses this to render the portal dashboard tiles.
      #
      # Response:
      # [
      #   { id, name, slug, icon_url }
      # ]
      # ─────────────────────────────────────────────────────────────
      def index
        portals = @user.portals.active.select(:id, :name, :slug, :icon_url)
        render json: portals.map { |p|
          { id: p.id, name: p.name, slug: p.slug, icon_url: p.icon_url }
        }
      end

      # ─────────────────────────────────────────────────────────────
      # GET /api/v1/portals/:slug/sso_url
      # Returns a signed SAML redirect URL for the selected portal.
      # Frontend does: window.location.href = response.redirect_url
      #
      # Response:
      # { redirect_url: "https://portal-sso-url?SAMLRequest=..." }
      # ─────────────────────────────────────────────────────────────
      def sso_url
        service = SamlSsoService.new(@portal, @user)
        url     = service.build_redirect_url

        if url.nil?
          render json: { error: service.error }, status: :unprocessable_entity
          return
        end

        render json: { redirect_url: url }
      end

      private

      def set_portal
        # Only allow access to portals the user is assigned to
        # Route passes :id but we use it as slug
        @portal = @user.portals.active.find_by(slug: params[:id])
        render json: { error: 'Portal not found or access denied' }, status: :not_found if @portal.nil?
      end
    end
  end
end
