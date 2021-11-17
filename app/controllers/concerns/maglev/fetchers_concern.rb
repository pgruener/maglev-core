# frozen_string_literal: true

module Maglev
  module FetchersConcern
    extend ActiveSupport::Concern

    included do
      helper_method :maglev_site, :maglev_theme, :maglev_page, :maglev_page_sections, :maglev_sections_path,
                    :maglev_site_root_fullpath, :maglev_page_fullpaths
    end

    private

    def fetch_maglev_page_content
      fetch_maglev_site
      fetch_maglev_theme
      fetch_maglev_page

      raise ActionController::RoutingError, 'Maglev page not found' unless fetch_maglev_page

      fetch_maglev_page_sections
    end

    def fetch_maglev_site
      @fetch_maglev_site ||= maglev_services.fetch_site.call
    end

    def fetch_maglev_page
      @fetch_maglev_page ||= maglev_services.fetch_page.call(
        path: params[:path],
        locale: content_locale,
        default_locale: default_content_locale,
        fallback_to_default_locale: fallback_to_default_locale
      )
    end

    def fetch_maglev_page_sections(page_sections = nil)
      @fetch_maglev_page_sections ||= maglev_services.get_page_sections.call(
        page: fetch_maglev_page,
        page_sections: page_sections,
        locale: content_locale
      )
    end

    def fetch_maglev_theme
      @fetch_maglev_theme ||= maglev_services.fetch_theme.call
    end

    def fetch_maglev_theme_layout
      @fetch_maglev_theme_layout ||= maglev_services.fetch_theme_layout.call
    end

    def fetch_maglev_sections_path
      @fetch_maglev_sections_path ||= maglev_services.fetch_sections_path.call
    end

    def fallback_to_default_locale
      false
    end

    ## accessors for view helpers ##

    def maglev_site
      fetch_maglev_site
    end

    def maglev_theme
      fetch_maglev_theme
    end

    def maglev_page
      fetch_maglev_page
    end

    def maglev_page_sections
      fetch_maglev_page_sections
    end

    def maglev_sections_path
      fetch_maglev_sections_path
    end

    def maglev_site_root_fullpath
      maglev_services.get_page_fullpath.call(
        path: 'index',
        locale: content_locale,
        preview_mode: maglev_rendering_mode != :live
      )
    end

    def maglev_page_fullpaths
      maglev_site.locale_prefixes.inject({}) do |memo, locale|
        memo.merge(locale => maglev_services.get_page_fullpath.call(
          page: maglev_page,
          locale: locale,
          preview_mode: maglev_rendering_mode != :live
        ))
      end
    end
  end
end
