<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title> CSI2441 Assignment 1: PHP </title>
    <link href="https://fonts.googleapis.com/css?family=Dosis|Livvic&display=swap" rel="stylesheet">
    <link rel="styleSheet" href ="styleSheet.css">
</head>
<body class = "body">
    <div><h1 class = "heading1"> Course Progression Analyser </h1></div>
        <main class = "container">
<?php
    //Declare variables to store data.
    $grandCPTotal = 0; $creditPointsRequired = 0;
    $unitsAttempted = 0; $unitsSuccessfullyCompleted = 0;
    $creditXScore = 0; 
    $failedUnits = array();     // Array to hold all failed units with the marks.
    $failedUnitCount = array();   // Array to hold failed units with attempt count.
    $allUnits = array();        // Array to hold all the units in the form with the attempt count.
    $error = false;
    $validRow = true;

    // Store user input data in variables.
    $firstName = $_POST["Firstname"];
    $surname = $_POST["Surname"];
    $studentID = $_POST["StudentID"];
    $courseType = $_POST["CourseType"];

    // Validate Student Data fields and iterate through 30 rows of units if valid inputs.
    $studentName = studentNameValidation($firstName, $surname);
    $stdID = studentIDValidation($studentID);
    $courseTypeName = getCourseTypeName($courseType);
    $courseCreditPoints = totalCreditPoints($courseType);

    for($row = 1; $row <= 30; $row++)
    {
        $unitCode = getUnitCode($row);
        $creditPoint = getCreditPoint($row);
        $yearSemester = getYearSemester($row);
        $unitMark = getMark($row);
        $validRow = isValidRow($unitCode, $creditPoint, $yearSemester, $unitMark);  // Check if each row is valid.

        // Check if the row is invalid.
        if(!$validRow)
        {
            $error = true;
            break;
        }

        // Check if the row is valid but not empty. If then, validate each unit field.
        if($validRow && !(empty($unitCode) && empty($creditPoint) && empty($yearSemester) && empty($unitMark)))
        {
            if(unitFieldsValidation($unitCode, $creditPoint, $yearSemester, $unitMark))
            {
                // Add all units to array 'allUnits'.
                if(array_key_exists($unitCode, $allUnits))
                {
                    $allUnits[$unitCode] += 1;
                }
                else if(!empty($unitCode))  // Else if it is not empty, add the unit code to the array
                {                           // and set the value to one.
                    $allUnits[$unitCode] = 1;
                }
                
                if(!empty($unitMark) && $unitMark >= 50 && is_numeric($unitMark))    // If unit mark is greater than 50, add to the grand total.
                {
                    $grandCPTotal += $creditPoint;
                    $unitsSuccessfullyCompleted += 1;   // Increase the count of passed units.
                    $creditXScore += ($creditPoint * $unitMark);  // Variable to store credit points multiplied by marks obtained.
                    // If the unit has been failed previously, and is passed now, remove the unit code from failed units.
                    if(array_key_exists($unitCode, $failedUnits))
                    {
                        unset($failedUnits[$unitCode]);
                        unset($failedUnitCount[$unitCode]);
                    }
                }
                else if(!empty($unitMark) && $unitMark < 50 && !empty($unitCode))
                {
                    $failedUnits[$unitCode] = $unitMark;    // Add the unit code & its unit mark to the array.
                    if(array_key_exists($unitCode, $failedUnitCount))  // If array key exists in failedUnitCount array, increment the value of that key. Else, add the key to the array.
                    {
                        $failedUnitCount[$unitCode] += 1;
                    }
                    elseif(!empty($unitCode))
                    {
                        $failedUnitCount[$unitCode] = 1;
                    }
                }
                $unitsAttempted = count($allUnits); // Get count of all units attempted.
            }
            else
            {
                $error = true;
                break;
            }
        }
        else
        {
            break;
        }
    }

    //Validate input data, if all data are true and no error, perform calculations to check course progression and display them.
    if($studentName && $stdID && $courseTypeName && !$error)
    {
        displayStudentDetails($firstName, $surname, $studentID, $courseTypeName); 
        $creditPointsRequired = $courseCreditPoints - $grandCPTotal;    // Calculate total credit points required to complete the course.
        $courseAvg = calculateCourseAvg($creditXScore, $grandCPTotal);  // Calculate Course Average.
        $currentCourseStatus = checkCourseStatus($grandCPTotal, $courseCreditPoints, $failedUnits, $failedUnitCount);    // Check course status.
        displayProgress($grandCPTotal, $courseCreditPoints, $unitsAttempted, $unitsSuccessfullyCompleted, $courseAvg, $currentCourseStatus);  
    }

    // Module to check if the unit row is valid or invalid.
    function isValidRow($unitCode, $creditPoint, $yearSemester, $unitMark)
    {
        // If all fields in the row are empty.
        if(empty($unitCode) && empty($creditPoint) && empty($yearSemester) && empty($unitMark))
        {
            return true;
        }

        // If atleast one field in a row is empty, content invalid.
        if(!(empty($unitCode) && empty($creditPoint) && empty($yearSemester) && empty($unitMark)) && (empty($unitCode) || empty($creditPoint)|| 
        empty($yearSemester) || empty($unitMark)))
        {
            echo "<p class = 'errorMessages'>** Invalid form data! A unit row must be completed in full to proceed. </ br></p>";
            return false;
        }

        return true;
    }

    function getUnitCode($rowNumber)    //Function gets the unit code from the form.
    {
        $unitCode = $_POST["UnitCode_".$rowNumber];
        return $unitCode;
    }

    function getCreditPoint($rowNumber)  //Function gets the credit point from the form.
    {
        $creditPoint = $_POST["CP_".$rowNumber];
        return $creditPoint;
    }

    function getYearSemester($rowNumber)    //Function gets the year/semester from the form.
    {
        $yearSemester = $_POST["YS_".$rowNumber];
        return $yearSemester;
    }

    function getMark($rowNumber)    //Function gets the unit mark from the form.
    {
        $unitMark = $_POST["UM_".$rowNumber];
        return $unitMark;
    }

    // Module for Credit Points Per Course.
    function totalCreditPoints($type)
    {
        $requiredCP = 0;
        if($type == 1)
        {
            return $requiredCP = 360;
        }
        elseif($type == 2)
        {
            return $requiredCP = 120;
        }
        elseif($type == 3)
        {
            return $requiredCP = 180;
        }
        elseif($type == 4)
        {
            return $requiredCP = 240;
        }
    }

    // Module to get the name of Course Type.
    function getCourseTypeName($type)
    {
        if($type == 1)
        {
            return "Undergraduate Degree";
        }
        elseif($type == 2)
        {
            return "Graduate Diploma";
        }
        elseif($type == 3)
        {
            return "Masters by Coursework";
        }
        elseif($type == 4)
        {
            return "Masters by Research";
        }
    }

    // Function to check the course status.
    function checkCourseStatus($creditPointsObtained, $coursePoints, $failedUnits,$failedUnitCount)
    {
        // Check if the student has completed more than 66% of the course.
        $completedAvg = ($creditPointsObtained / $coursePoints)*100;
        $completion = ($completedAvg > 66.6 ? true : false );

        // Check if student has failed a single unit and is eligible for a supp assessment or conceded pass.
        if(count($failedUnits) == 1)
        {
            foreach ($failedUnits as $unitCode => $unitMark) 
            {
                if($unitMark >= 40 && $unitMark <= 45 && $completion)
                {
                    return "Unit ID: <strong>" . $unitCode . "</strong> has been given a <strong>Supplementary Assessment</strong><br/>";
                }

                elseif($unitMark >= 46 && $unitMark <= 49 && $completion)
                {
                    return "Unit ID: <strong>" . $unitCode . "</strong> has been given a <strong>Conceded Pass</strong><br/>";
                }
            }
        }

        foreach ($failedUnitCount as $unitCode => $attempts) 
        {
            if($attempts > 2)
            {
                return "<strong>EXCLUDED FROM COURSE! </strong><br/>";
            }
        }

        // If obtained more points than the required points, indicate course complete. Else, calculate the number of
        // credit points required for the student to complete the course.
        if($creditPointsObtained > $coursePoints)
        {
            return "<strong>SUCCESSFULLY COMPLETED! </strong></br>";
        }

        else
        {
            $CPForCompletion = $coursePoints - $creditPointsObtained;
            return "<strong>$CPForCompletion CP</strong> Required for Completion</br>";
        }
    }
 
    // Calculate course average module.
    function calculateCourseAvg($avgScoreCredit, $creditPointTotal)
    {
        //Calculate Average.
        if($creditPointTotal > 0)
        {
            $courseAverage = round(($avgScoreCredit / $creditPointTotal), 0, PHP_ROUND_HALF_UP);

            // Display course average Marks and Grade.
            if($courseAverage >= 50 && $courseAverage < 60)
            {
                return "$courseAverage  (Pass)";
            }

            elseif($courseAverage >= 60 && $courseAverage < 70)
            {
                return "$courseAverage  (Credit)";
            }

            elseif($courseAverage >= 70 && $courseAverage < 80)
            {
                return "$courseAverage  (Distinction)";
            }

            elseif($courseAverage >= 80)
            {
                return "$courseAverage  (High-Distinction)";
            }
        }
        return "Fail";
    }

    // Function to validate the first name of the student.
    function studentNameValidation($firstName, $lastName)
    {
    // Both name fields cannot be empty.
    if(empty($firstName) || empty($lastName))
    {
        echo "<p class = 'errorMessages'>** The First Name or Surname cannot be empty! </br></p>";
        return false;
    }
    // Both first name and surname cannot be the same.
    elseif (!(empty($firstName) || empty($lastName)) && $firstName == $lastName)
    {
        echo "<p class = 'errorMessages'>** The first name and the surname cannot be the same. </br> Please try again! </br></p>";
        return false;
    }
    // Both first name and surname has a minimum length of 2.
    elseif (!(empty($firstName) || empty($lastName)) && strlen($firstName) < 2 || strlen($lastName) < 2)
    {
        echo "<p class = 'errorMessages'>** Invalid First Name or Surname! </br></p>";
        return false;
    }
    // Both name fields cannot contain digits or special characters.
    elseif (!ctype_alpha($firstName) || !ctype_alpha($lastName))
    {
        echo "<p class = 'errorMessages'>** The Name fields cannot contain digits or other characters! </br></p>";
        return false;
    }
    return true;
}        

// Student ID validation
function studentIDValidation($studentID)
{
    // If student ID field is empty.
    if(empty($studentID))
    {
        echo "<p class = 'errorMessages'>** The Student ID cannot be empty! </br></p>";
        return false;
    }
    // If student ID is 8 characters in length.
    elseif(!(empty($studentID)) && strlen($studentID) != 8)
    {
        echo "<p class = 'errorMessages'>** Invalid Student ID! </br></p>";
        return false;
    }
    // If student ID contains only digits.
    elseif(!(empty($studentID)) && !is_numeric($studentID)) 
    {
        echo "<p class = 'errorMessages'>** The Student ID can only contain numeric characters! </br></p>";
        return false;
    }
    return true;
}


function unitFieldsValidation($unitCode, $creditPoint, $yearSem, $unitMark)
{
    // Unit Code Validation.
    // Check if length of unit code is 7.
    if(strlen($unitCode) != "7")
    {
        echo "<p class = 'errorMessages'>** Invalid Unit Code. It must contain 7 characters. <br></p>";
        return false;
    }
    // Check if unit code contains only numbers and letters.
    elseif(!ctype_alnum($unitCode))
    {
        echo "<p class = 'errorMessages'>** Invalid Unit Code. Please enter a valid unit code. </br></p>";
        return false;
    }
    // Check if unit code contains a mix of both numbers and letters.
    elseif(ctype_alpha($unitCode) || ctype_digit($unitCode))
    {
        echo "<p class = 'errorMessages'>** A valid unit code contains letters and numbers. Please enter a valid unit code. </br></p>";
        return false;
    }

    // Credit Points validation.
    // Check if the credit point value is 15 or 20, nothing else.
    elseif($creditPoint != 15 && $creditPoint != 20)
    {
        echo "<p class = 'errorMessages'>** Credit Points value can only be a 15 or a 20. </br></p>";
        return false;
    }

    // Year/Semester Validation.
    // If length of semester ID is equal to 3.
    else if(strlen($yearSem) != "3" || empty($yearSem) || !is_numeric($yearSem))
    {
        echo "<p class = 'errorMessages'>** Invalid length of string or semester number. </br></p>";
        return false;
    }
    // Student Marks Validation.
    // If the mark is not numeric.
    elseif(!is_numeric($unitMark))
    {
        echo "<p class = 'errorMessages'>** Invalid marks! </br></p>";
        return false;
    }   
    // If the mark is greater than 100 or less than 10.
    elseif($unitMark < 0 || $unitMark > 100)
    {
        echo "<p class = 'errorMessages'>** Invalid marks. Unit mark must be in between 0 and 100. </br></p>";
        return false;
    }
    return true;
}

?>
<?php
    //////////  DISPLAY DETAILS //////////
    /////////   //////////  //////////
    function displayStudentDetails($firstName, $surname, $studentID, $courseTypeName)
    {
?>      <!-- Display Student Data. -->
        <div class = "studentDetails">
            <h4>
                <table align="center">
                    <tr>
                        <td><strong> Student ID: </strong></td>
                        <td><?php echo "$studentID" ?></br></td>
                    </tr>
                    <tr>
                        <td><strong> Student Name: &nbsp;</strong></td>
                        <td><?php echo "$firstName $surname" ?></br></td>
                    </tr>
                    <tr>
                        <td><strong> Course Type: </strong></td>
                        <td><?php echo "$courseTypeName" ?></br></td>
                    </tr>
                </table>
            </h4>
        </div>
<?php
    }
?>

<?php
    // Module for displaying progress data.
    function displayProgress($CPObtained, $CPRequired, $noOfAttemptedUnits, $fullyCompletedUnits, $currentCourseAvg, $statusOfCourse)
    {
?>
        <!-- Display Progress -->
        <div class = "progressDetails">
            <table width = "500" align ="center">
                <tr>
                    <td width = "400">Credit Points Required: </td>
                    <td><?php echo "$CPRequired"; ?></td>
                </tr>
                <tr>
                    <td>Total Passed Credit Points: </td>
                    <td><?php echo "$CPObtained"; ?></td>
                </tr>
                <tr>
                    <td>No. of Units Attempted: </td>
                    <td><?php echo "$noOfAttemptedUnits"; ?></td>
                </tr>
                <tr>
                    <td>No. of Units Successfully Completed: &nbsp; </td>
                    <td><?php echo "$fullyCompletedUnits"; ?></td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>Course Average:&nbsp; </td>
                    <td><?php echo "$currentCourseAvg"; ?></td>
                </tr>
                <tr>
                    <td>Course Status:&nbsp; </td>
                    <td width = 500><?php echo "$statusOfCourse"; ?></td>
                </tr>
            </table>
        </div>
<?php
    }
?>
</main>
</body>
<footer>&nbsp;</footer>
</html>