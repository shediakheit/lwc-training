public class DeliveryConstructor {

    public static void addDelivery(int deliveries, Course__c course, List<User> instructors) {
        for(int i = 0; i < deliveries; i++) {
            Course_Delivery__c cd = new Course_Delivery__c();
            cd.Instructor__c = instructors.get(i);
            insert cd;
        }
    }
}