import { LightningElement, track } from 'lwc';

export default class KoosaBatikh extends LightningElement {
    
    masterEmployeeList = [
        { id: '1', name: 'Alex Smith', department: 'Sales', role: 'Account Manager', email: 'alex@company.com' },
        { id: '2', name: 'Sam Johnson', department: 'Sales', role: 'Sales Rep', email: 'sam@company.com' },
        { id: '3', name: 'Jane Doe', department: 'Engineering', role: 'Software Engineer', email: 'jane@company.com' },
        { id: '4', name: 'Chris Lee', department: 'Engineering', role: 'QA Engineer', email: 'chris@company.com' },
        { id: '5', name: 'Taylor Wong', department: 'HR', role: 'HR Specialist', email: 'taylor@company.com' }
    ];
 
    selectedDepartmentValue = ''; 
    filteredEmployees = [];       
    selectedEmployee = null;      
 
    get departmentOptions() {
        const uniqueDeps = [...new Set(this.masterEmployeeList.map(emp => emp.department))];
        return uniqueDeps.map(dep => ({ label: dep, value: dep }));
    }
 
    handleDepartmentChange(event) {
      
        this.selectedDepartmentValue = event.detail.value;
    }
 
    handleFilterClick() {
       
        if (!this.selectedDepartmentValue) return;

        
        this.filteredEmployees = this.masterEmployeeList.filter(
            emp => emp.department === this.selectedDepartmentValue
        ); 
        this.selectedEmployee = null;
    }
 
    handleEmployeeClick(event) {
       
        const targetId = event.currentTarget.dataset.id;
 
        this.selectedEmployee = this.masterEmployeeList.find(emp => emp.id === targetId);
    }
}
