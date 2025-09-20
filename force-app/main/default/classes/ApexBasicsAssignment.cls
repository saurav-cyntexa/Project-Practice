/**
 * @description     ApexBasicsAssignment class contains solutions for both 
 *                  basic and intermediate coding questions given in the 
 *                  Cyntexa Salesforce development training assignment.
 *
 * @author          Saurav Kumar
 */
public class ApexBasicsAssignment {
    
    /**
     * @description     Checks if the provided string is a palindrome 
     *                  (reads the same forward and backward).
     *
     * @author          Saurav Kumar
     * @param str       Input string to be checked.
     * @return Boolean  True if the string is a palindrome, false otherwise.
     */
    public static Boolean isPalindrome(String str) {
        Integer left = 0; 
        Integer right = str.length() - 1;
        while (left <= right) {
            if (str.charAt(left) != str.charAt(right)) {
                return false;
            }
            left++;
            right--;
        }
        return true;
    }
    

    /**
     * @description     Calculates the sum of digits of a given integer.
     *
     * @author          Saurav Kumar
     * @param num       The input integer.
     * @return Integer  Sum of all digits of the integer.
     */
    public static Integer sumOfDigits(Integer num) {
        Integer sum = 0;
        while (num > 0) {
            Integer digit = Math.mod(num, 10);
            sum += digit;
            num = num / 10;
        }
        return sum;
    }
    

    /**
     * @description          Reverses the order of elements in a list.  
     *                       (Done without using predefined reverse functions.)
     *
     * @author               Saurav Kumar
     * @param inputList      The input list of integers.
     * @return List<Integer> The list with elements in reversed order.
     */
    public static List<Integer> reverseList(List<Integer> inputList) {
        Integer left = 0, right = inputList.size() - 1;
        while (left <= right) {
            Integer temp = inputList[left];
            inputList[left] = inputList[right];
            inputList[right] = temp;
            left++;
            right--;
        }
        return inputList;
    }
    

    /**
     * @description                         Converts a 2D list of integers into a map, 
     *                                      where the key is the row index and the value 
     *                                      is the list of unique integers in that row.
     *
     * @author                              Saurav Kumar
     * @param inputList                     A 2D list of integers.
     * @return Map<Integer, List<Integer>>  Map of row index and corresponding unique integer list.
     */
    public static Map<Integer, List<Integer>> map2DList(List<List<Integer>> inputList) {
        Map<Integer, List<Integer>> resultMap = new Map<Integer, List<Integer>>();
        for (Integer i = 0; i < inputList.size(); i++) {
            Set<Integer> s = new Set<Integer>(inputList[i]);
            resultMap.put(i, new List<Integer>(s));       
        }
        return resultMap;
    }
    

    /**
     * @description               Removes duplicate values inside each string of a 2D list, 
     *                            sorts the values, and returns the updated list.
     *
     * @author                    Saurav Kumar
     * @param inputList           A 2D list of strings (each string contains ';' separated values).
     * @return List<List<String>> A 2D list with duplicates removed and values sorted.
     */
    public static List<List<String>> removeDuplicatesAndSort(List<List<String>> inputList) {
        for (Integer i = 0; i < inputList.size(); i++) {
            for (Integer j = 0; j < inputList[i].size(); j++) {
                String str = inputList[i][j];
                List<String> strList = str.split(';');
                strList.sort();
                Set<String> strSet = new Set<String>(strList);
                String joinedString = String.join(strSet, ';');
                inputList[i][j] = joinedString;
            }
        }
        return inputList;
    }
    

    /**
     * @description             Rotates the list clockwise (to the right) by k positions.
     *
     * @author                  Saurav Kumar
     * @param inputList         The input list of integers.
     * @param k                 Number of positions to rotate.
     * @return List<Integer>    The rotated list.
     */
    public static List<Integer> rotateClockwise(List<Integer> inputList, Integer k) {
        Integer n = inputList.size();
        k = Math.mod(k, n);
        List<Integer> rotatedList = new List<Integer>();
        for (Integer i = n - k; i < n; i++) {
            rotatedList.add(inputList[i]);
        }
        for (Integer i = 0; i < n - k; i++) {
            rotatedList.add(inputList[i]);
        }
        return rotatedList;
    }
    

    /**
     * @description             Rotates the list anticlockwise (to the left) by k positions.
     *
     * @author                  Saurav Kumar
     * @param inputList         The input list of integers.
     * @param k                 Number of positions to rotate.
     * @return List<Integer>    The rotated list.
     */
    public static List<Integer> rotateAntiClockwise(List<Integer> inputList, Integer k) {
        Integer n = inputList.size();
        k = Math.mod(k, n);
        List<Integer> rotatedList = new List<Integer>();
        for (Integer i = k; i < n; i++) {
            rotatedList.add(inputList[i]);
        }
        for (Integer i = 0; i < k; i++) {
            rotatedList.add(inputList[i]);
        }
        return rotatedList;        
    }
    

    /**
     * @description             Finds all leaders in the list.  
     *                          An element is a leader if it is greater than all elements to its right.
     *
     * @author                  Saurav Kumar
     * @param inputList         The input list of integers.
     * @return List<Integer>    A list of leader elements.
     */
    public static List<Integer> findLeaders(List<Integer> inputList) {
        List<Integer> leadersList = new List<Integer>{inputList[inputList.size() - 1]};
        Integer currLeader = leadersList[0];
        for (Integer i = inputList.size() - 2; i >= 0; i--) {
            if (inputList[i] > currLeader) {
                leadersList.add(inputList[i]);
                currLeader = inputList[i];
            }
        }
        return leadersList;
    }
}
