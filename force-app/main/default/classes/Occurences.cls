public with sharing class Occurences {
    public static void countOccurences(List<String> arr) {
        Map<String, Integer> m = new Map<String, Integer>();
        for(String s : arr) {
            if(m.containsKey(s)) {
                m.put(s, m.get(s)+1);
            } else {
                m.put(s, 1);
            }
        }
        System.Debug(m);
    }
}