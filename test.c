#include "printf.h"

int main() {
    char* testString1 = "Hello, world!";
    char* testString2 = "Evil hello world >:D";
    char* testString3 = "String 3";
    char* testString4 = "String 4";
    char* testString5 = "String 5";
    printf("First string: %s\nSecond string: %s\n%s\n%s\n%s\n%s\n", testString1, testString2, testString3, testString4, testString5);

    return 0;
}