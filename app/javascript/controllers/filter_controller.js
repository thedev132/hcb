import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ["tagsLabel", "usersLabel", "typesLabel", "tags", "users", "types"];

  selectTags(mouseEvent) {
    this.tagsLabelTarget.dataset.filterMenuLabelSelected = mouseEvent ? "true" : "false";
    this.tagsTarget.dataset.filterMenuSelected = mouseEvent ? "true" : "false";
    if(mouseEvent !== undefined){
      this.selectTypes();
      this.selectUsers();
    }
  }

  selectUsers(mouseEvent) {
    this.usersLabelTarget.dataset.filterMenuLabelSelected = mouseEvent ? "true" : "false";
    this.usersTarget.dataset.filterMenuSelected = mouseEvent ? "true" : "false";
    if(mouseEvent !== undefined){
      this.selectTypes();
      if(this.hasTagsTarget){
        this.selectTags();
      }
    }
  }

  selectTypes(mouseEvent) {
    this.typesLabelTarget.dataset.filterMenuLabelSelected = mouseEvent ? "true" : "false";
    this.typesTarget.dataset.filterMenuSelected = mouseEvent ? "true" : "false";
    if(mouseEvent !== undefined){
      this.selectUsers();
      if(this.hasTagsTarget){
        this.selectTags();
      }
    }
  }
}
