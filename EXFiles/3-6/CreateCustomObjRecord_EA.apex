//TODO #1  Declare a variable whose type is Course__c named newCourse  
//         and initialize it to a newly constructed Course__c sObject,
//         assigning the field Name the value '[104] Introduction to Programming',
//         the field Course_Description__c the value 'Learn the basics of programming with OOP',
//         the field Status__c the value 'Active',
//         the field Duration__c the value 5.

//TODO #2  Use the insert statement to insert newCourse into the database.


 public void addDelivery(int deliveries, Course__c course, List<User> instructors) {
        for(int i = 0; i < deliveries; i++) {
            Course_Delivery__c cd = new Course_Delivery__c();
            cd.Instructor__c = instructors.get(i);
            insert cd;
        }
    }
Course__c newCourse = new Course__c();
newCourse.Name = 'Introduction to Programming';
newCourse.Description__c = 'Learn the basics of programming with OOP';
newCourse.Status__c = 'Active';
newCourse.Duration__c = 5;
insert newCourse;
// DeliveryConstructor dc = new DeliveryConstructor()
// Course_Delivery__c newCd = new Course_Delivery__c();
// newCd.Course__c = newCourse.id;
// insert newCd;
User instructor1 = new User();
User instructor2 = new User();
List<User> instructors = new List<User>();
instructors.add(instructor1);
instructors.add(instructor2);
DeliveryConstructor.addDelivery(2, newCourse, instructors);
// Course__c c = new Course__c();
// c.Name = 'Intro';

