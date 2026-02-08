public with sharing class UtilityString {

    public static String getSubStringIfMaxCharsExceeded(String stringToGetFrom, Integer maxCharactersToGet) {

        if (!String.isEmpty(stringToGetFrom) && stringToGetFrom.length() > maxCharactersToGet) {
            stringToGetFrom = stringToGetFrom.substring(0, maxCharactersToGet);
        }
        return stringToGetFrom;
    }
}