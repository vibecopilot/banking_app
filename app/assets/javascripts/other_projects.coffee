# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '#add-amenity', (e) ->
  e.preventDefault()
  time = new Date().getTime()
  html = '<div class="field">' +
    '<label for="other_project_other_p_amenities_attributes_' + time + '_name">Name</label>' +
    '<input type="text" name="other_project[other_p_amenities_attributes][' + time + '][name]" id="other_project_other_p_amenities_attributes_' + time + '_name">' +
    '<label for="amenity_icon_' + time + '">Icon</label>' +
    '<input type="file" name="amenity_icons[' + time + ']" id="amenity_icon_' + time + '">' +
    '<input type="hidden" name="other_project[other_p_amenities_attributes][' + time + '][_destroy]" value="false">' +
    '<a href="#" class="remove-amenity" data-time="' + time + '">Remove</a>' +
    '</div>'
  $('#other_p_amenities').append(html)

$(document).on 'click', '.remove-amenity', (e) ->
  e.preventDefault()
  $(this).parent('.field').hide()
  $(this).siblings('input[name$="[_destroy]"]').val('1')
  # Also hide the parent fieldset


