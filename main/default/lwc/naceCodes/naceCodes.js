import { LightningElement, track, api, wire } from 'lwc';
import getHierarchy from '@salesforce/apex/LocationTreeController.getHierarchy';
import getNaceIdByExternalId from '@salesforce/apex/LocationTreeController.getNaceIdByExternalId';

export default class naceCodes extends LightningElement {
    @api recordId;
    //rendered = false;
    @track items;
    @track hasRendered = true;
    externalIdValue = 'extID-398481'; // Replace with your external ID value

    @wire(getNaceIdByExternalId, { externalIdValue: '$externalIdValue' })
    naceEvent;

    renderedCallback() {
        console.log('LWC begin callback ' + this.hasRendered);
        if (this.hasRendered) {
            console.log('LWC begin if callback ' + this.hasRendered);
         
            console.log('LWC in renderedCallback Nace ID is ' + this.naceEvent.data);
            getHierarchy({ recordId: this.naceEvent.data })
                .then(result => {
                    this.items = [];
                    const originalId = result.originalId;
                    let rootLoc = result.rootLocation;
                    this.items.push(this.getItemFromLocation(rootLoc, null, true));
                    let parentLevel = this.items;
                    for (let level of result.masterList) {
                        let tempParentLevel = [];
                        for (let [parentId, locationList] of Object.entries(level)) {
                            for (let location of locationList) {
                                let currentParent = parentLevel.find(el => {
                                    return el.name === location.Parent_Code__c;
                                });
                                let newItem = this.getItemFromLocation(location, currentParent);                                
                                if (location.Id === originalId) {
                                    newItem.expanded = true;
                                    this.expandChain(newItem);
                                }                                
                                currentParent.items.push(newItem);
                                tempParentLevel.push(newItem);
                            }
                        }
                        parentLevel = tempParentLevel;
                        
                    }
                    this.hasRendered = false;
                    console.log('LWC end callback ' + this.hasRendered);
                })
                .catch(error => {
                    console.log('LWC error callback ' + this.hasRendered);
                    console.log('error', error);
                })
        }
    }

    getItemFromLocation(location, parent, expanded) {
        return {
            label: location.Name,
            name: location.Id,
            metatext: location.Description__c,
            href: '/' + location.Id,
            parent: parent,
            expanded: expanded,
            items: []
        }
    }    

    // Loop upwards and expand all parents in the chain from the "original" location
    expandChain(item) {
        while (item.parent) {
            item.parent.expanded = true;
            item = item.parent;
        }
    }
}