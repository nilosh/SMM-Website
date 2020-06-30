<%@ Page Language="C#" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>CSI2441 Course Progression Analyser</title>
    <link href="https://fonts.googleapis.com/css?family=Dosis|Livvic&display=swap" rel="stylesheet">
    <link rel="styleSheet" href="styleSheet.css">
    <script runat="server">

        // Declare variables to store data.
        string firstName, surname, courseType, studentID;
        string unitCode;
        int creditPoint, yearSemester, marks;

        // Validate Student Data fields.
        public Boolean validateInputData(string firstName, string surname, string studentID)
        {
            bool errorFlag = false;

            // Validate Name.
            // If the first name contains numeric or special characters.
            if (!(Regex.IsMatch(firstName, @"[a-zA-Z]+$")))
            {
                Response.Write("<p class = 'errorMessages'>** Firstname should be an alphabetic string. </br>");
                errorFlag = true;
            }

            // If the surname contains numeric or special characters.
            if (!(Regex.IsMatch(surname, @"^[a-zA-Z]+$")))
            {
                Response.Write("<p class = 'errorMessages'>** Surname should be an alphabetic string. </br>");
                errorFlag = true;
            }

            // If the first name and the last name are the same.
            else if (firstName == surname)
            {
                Response.Write("<p class = 'errorMessages'>** Both First Name and Last Name cannot be the same. </br>");
                errorFlag = true;
            }

            // If the length of the first name or the surname is less than 2 letters.
            else if (firstName.Length < 2 || surname.Length < 2)
            {
                Response.Write("<p class = 'errorMessages'>** Invalid Name! A name must be atleast two letters. </br>");
                errorFlag = true;
            }

            // Validate Student ID.
            // If Student ID field is empty.
            if (String.IsNullOrWhiteSpace(studentID))
            {
                Response.Write("<p class = 'errorMessages'>** The Student ID cannot be empty! </br>");
                errorFlag = true;
            }

            // If length of Student ID is 8.
            else if (!String.IsNullOrWhiteSpace(studentID) && studentID.ToString().Length != 8)
            {
                Response.Write("<p class = 'errorMessages'>** Invalid Student ID. </br>");
                errorFlag = true;
            }

            // else if Student ID is numerical.
            else if (!String.IsNullOrWhiteSpace(studentID) && !int.TryParse(studentID, out int StdID))
            {
                Response.Write("<p class = 'errorMessages'>** Student ID should be numerical. </br>");
                errorFlag = true;
            }

            return errorFlag;
        }

        public Boolean isValidRow(string unitCode, string creditPoint, string yearSemester, string marks)
        {
            // Check if all the fields in the row are empty.
            if (String.IsNullOrWhiteSpace(unitCode) && String.IsNullOrWhiteSpace(creditPoint) && String.IsNullOrWhiteSpace(yearSemester) && String.IsNullOrWhiteSpace(marks))
            {
                return true;
            }
            // Check if atleast one field is empty in a row. If so, return false.
            if (!(String.IsNullOrWhiteSpace(unitCode) && String.IsNullOrWhiteSpace(creditPoint) && String.IsNullOrWhiteSpace(yearSemester) && String.IsNullOrWhiteSpace(marks))
                && (String.IsNullOrWhiteSpace(unitCode) || String.IsNullOrWhiteSpace(creditPoint) || String.IsNullOrWhiteSpace(yearSemester) || String.IsNullOrWhiteSpace(marks)))
            {
                Response.Write("<p class = 'errorMessages'>** Invalid form data! A unit row must be completed in full to proceed. </ br></p>");
                return false;
            }

            else
            {
                return true;
            }
        }

        public Boolean unitFieldsValidation(string currentUnitCode, string currentCreditPoint, string currentYearSemester, string currentMark)
        {
            // Validate Unit Code.
            // If length of Unit Code is not 7.
            if (currentUnitCode.Length != 7)
            {
                Response.Write("<p class = 'errorMessages'>** Invalid Unit Code. It must contain 7 characters. <br></p>");
                return false;
            }

            else if (!(Regex.IsMatch(currentUnitCode, @"^[a-zA-Z0-9]+$")))   // Is alpha-numeric
            {
                Response.Write("<p class = 'errorMessages'>** Invalid Unit Code. Please enter a valid unit code. </br></p>");
                return false;
            }

            else if (int.TryParse(currentUnitCode, out int currUC) || Regex.IsMatch(currentUnitCode, @"^[a-zA-Z]+$")) //If either only alpha or only numeric.
            {
                Response.Write("<p class = 'errorMessages'>** A valid unit code contains letters and numbers. Please enter a valid unit code. </br></p>");
                return false;
            }

            // Validate Credit Points
            // Check if the field is numeric.
            if (!int.TryParse(currentCreditPoint, out int currCP))
            {
                Response.Write("<p class = 'errorMessages'>** Credit Points value must be numeric. </br></p>");
                return false;
            }
            // Check if Credit Points is either 15 or 20.
            if ((currCP != 15 && currCP != 20))// && !int.TryParse(currentCP, out int currCP))
            {
                Response.Write("<p class = 'errorMessages'>** Credit Points value can only be a 15 or a 20. </br></p>");
                return false;
            }

            // Validate Year/Semester.
            // Check if length is 3 and is not empty.
            if (String.IsNullOrWhiteSpace(currentYearSemester) && currentYearSemester.Length != 3)
            {
                Response.Write("<p class = 'errorMessages'>** Invalid length of string or semester number. </br></p>");
                return false;
            }

            else if (!int.TryParse(currentYearSemester, out int currYS))
            {
                Response.Write("<p class = 'errorMessages'>** Semester ID must be numerical. </br></p>");
                return false;
            }

            // Validate Marks.
            if (!int.TryParse(currentMark, out int currScore))   // Check if the marks field is not numeric.
            {
                Response.Write("<p class = 'errorMessages'>** Invalid marks! </br></p>");
                return false;
            }

            else if (int.Parse(currentMark) < 0 || int.Parse(currentMark) > 100)   // Check if marks in between 0 and 100.
            {
                Response.Write("<p class = 'errorMessages'>** Invalid marks. Unit mark must be in between 0 and 100. </br></p>");
                return false;
            }

            return true;
        }

        public int setCreditPoint(int row)      // Get credit point value from the form and convert it to an int.
        {
            int currCP;
            bool currentCreditPoint = int.TryParse(Request.Form["CP_" + row], out currCP);
            return currCP;
        }

        public int setYearSemester(int row)     // Get year semester from the form and convert it to an int.
        {
            bool currentYearSemester = int.TryParse(Request.Form["YS_" + row], out int currYS);
            return currYS;
        }

        public int setMarks(int row)        // Get marks from the form and convert it to an int.
        {
            bool currentMarks = int.TryParse(Request.Form["UM_" + row], out int currUM);
            return currUM;
        }

        public String getCourseType()       // Get the course type name to display instead of the type numbers.
        {
            bool courseType = int.TryParse(Request.Form["CourseType"], out int type);
            if (type == 1)
            {
                return "Undergraduate Degree";
            }
            else if (type == 2)
            {
                return "Graduate Diploma";
            }
            else if (type == 3)
            {
                return "Masters by Coursework";
            }
            else
            {
                return "Masters by Research";
            }
        }

        public int getRequiredCP(string courseType)     // Get the credit points required for completion for each course type.
        {
            if (courseType == "Undergraduate Degree")
            {
                return 360;
            }
            else if (courseType == "Graduate Diploma")
            {
                return 120;
            }
            else if (courseType == "Masters by Coursework")
            {
                return 180;
            }
            else
            {
                return 240;     // If Masters by Research.
            }
        }

        public String calculateCourseAverage(int creditTimesMarks, int creditPointTotal)    //   calculate the current course average.
        {
            if (creditPointTotal > 0)
            {
                int courseAverage = (creditTimesMarks / creditPointTotal);
                if (courseAverage >= 50 && courseAverage < 60)
                {
                    return courseAverage + "    (Pass)";
                }
                else if (courseAverage >= 60 && courseAverage < 70)
                {
                    return courseAverage + "    (Credit)";
                }
                else if (courseAverage >= 70 && courseAverage < 80)
                {
                    return courseAverage + "    (Distinction)";
                }
                else if (courseAverage >= 80 && courseAverage <= 100)
                {
                    return courseAverage + "    (High Distinction)";
                }
            }
            return "Fail";
        }

        public String checkCourseStatus(int creditPointTotal, int courseCreditPoints, Dictionary<string, int> failedUnits, Dictionary<string, int> unitAttempts)
        {
            int creditPointsForCompletion = 0;
            double completedPercentage = ((double)creditPointTotal / courseCreditPoints) * 100;

            bool completion = completedPercentage > 66.6 ? true : false;      // If the average completion is greater than 66%, set true.
            if (failedUnits.Count() == 1 && completion)     // If no. of failed units is 1, and has completed 66% of the course,
            {
                foreach (KeyValuePair<string, int> mark in failedUnits)
                {
                    if (mark.Value >= 40 && mark.Value <= 45)        // If marks in between 40 and 45, student gets a supplementary assessment.
                    {
                        return "Unit ID: <strong>" + mark.Key + "</strong> has been given a <strong>Supplementary Assessment</strong><br/>";
                    }

                    else if (mark.Value >= 46 && mark.Value <= 49)   // If marks in between 46 and 49, student gets a conceded pass.
                    {
                        return "Unit ID: <strong>" + mark.Value + "</strong> has been given a <strong>Conceded Pass</strong><br/>";
                    }
                }
            }

            foreach (KeyValuePair<string, int> attempts in unitAttempts)
            {
                if (attempts.Value > 2)  //If the no. of attempts for one unit is 3, the person will be excluded from the course.
                {
                    return "<strong>EXCLUDED FROM COURSE! </strong><br/>";
                }
            }

            if (creditPointTotal > courseCreditPoints)   // Check if the total credit points obtained is greater than the required. If so, display successfully completed
            {
                return "<strong>SUCCESSFULLY COMPLETED! </strong></br>";
            }
            else                // Else, calculate the credit points required for completion and display.
            {
                creditPointsForCompletion = courseCreditPoints - creditPointTotal;
                return "<strong>" + creditPointsForCompletion + " CP</strong> Required for Completion</br>";
            }
        }

    </script>
</head>
<body class="body">
    <div>
        <h1 class="heading1">Course Progression Analyser </h1>
    </div>
    <main class="container">
        <%  // Initialize variables.
            int creditPointTotal = 0, creditPointRequired = 0, unitsAttempted = 0, unitsSuccessfullyCompleted = 0, creditTimesMarks = 0;
            bool validRow = true;

            // Get user data and assign to variables.
            firstName = Request.Form["Firstname"];
            surname = Request.Form["Surname"];
            studentID = Request.Form["StudentID"];
            courseType = getCourseType();

            // Validate these input data on student details.
            bool invalidInputs = validateInputData(firstName, surname, studentID);
            int courseCreditPoints = getRequiredCP(courseType);     // Get course type name.
            bool error = false;
            Dictionary<string, int> failedUnits = new Dictionary<string, int>();  // Dictionary holds unit code and marks as key and value of failed units.
            Dictionary<string, int> unitAttempts = new Dictionary<string, int>();    // Dictionary holds unit code and no of attempts as key and value.
            Dictionary<string, int> allUnits = new Dictionary<string, int>();   // Dictionary holds unit code and no of attempts of that Unit for all units.

            if (!invalidInputs)
            {
                // Get each row detail.
                for (int row = 1; row <= 30; row++)
                {
                    // Get each unit field detail.
                    unitCode = Request.Form["UnitCode_" + row];
                    creditPoint = setCreditPoint(row);
                    yearSemester = setYearSemester(row);
                    marks = setMarks(row);

                    validRow = isValidRow(unitCode, Request.Form["CP_" + row], Request.Form["YS_" + row], Request.Form["UM_" + row]);  // Check if the row is valid. If the row is valid and not empty, validate each unit field.
                    if(!validRow)
                    {
                        error = true;
                        break;
                    }
                    if (validRow && !(String.IsNullOrWhiteSpace(unitCode) && String.IsNullOrWhiteSpace(Request.Form["CP_" + row]) && String.IsNullOrWhiteSpace(Request.Form["YS_" + row]) && String.IsNullOrWhiteSpace(Request.Form["UM_" + row])))
                    {
                        if (unitFieldsValidation(unitCode, Request.Form["CP_" + row], Request.Form["YS_" + row], Request.Form["UM_" + row]))
                        {
                            //If unit code already exist, increment the number of attempts of that unit code.
                            if (allUnits.ContainsKey(unitCode))
                            {
                                allUnits[unitCode] += 1;
                            }

                            else
                            {
                                allUnits.Add(unitCode, 1);  // Else, add the unit code to the dictionary and set the count to 1.
                            }

                            // If marks are greater than 50, sum up credit points, increment successfully completed units, multiply the credit points by units and
                            //sum it up. 
                            if (!String.IsNullOrWhiteSpace(marks.ToString()) && !String.IsNullOrWhiteSpace(unitCode) && marks >= 50)
                            {
                                creditPointTotal += creditPoint;
                                unitsSuccessfullyCompleted += 1;
                                creditTimesMarks += (creditPoint * marks);

                                if(failedUnits.ContainsKey(unitCode) && unitAttempts.ContainsKey(unitCode)) // Check if the student has failed the unit previously. If passed, remove the unit from the failed units arrays.
                                {
                                    failedUnits.Remove(unitCode);
                                    unitAttempts.Remove(unitCode);
                                }
                                //error = false;
                            }
                            //Else if marks less than 50, add them to failed units array. Increment attempt count in unitAttempts array if unit already exist.
                            else if (!String.IsNullOrWhiteSpace(marks.ToString()) && marks < 50 && !String.IsNullOrWhiteSpace(unitCode))
                            {
                                failedUnits[unitCode] = marks;
                                if (unitAttempts.ContainsKey(unitCode))
                                {
                                    unitAttempts[unitCode] += 1;
                                }

                                else if (!String.IsNullOrWhiteSpace(unitCode))
                                {
                                    unitAttempts.Add(unitCode, 1);
                                }
                            }
                            // Count the number of elements in the all unit count array.
                            unitsAttempted = allUnits.Count();
                        }

                        else
                        {
                            error = true;
                            break;
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }

            if (!invalidInputs && !error) //If no error, calculate CP, course average and course status.
            {
                creditPointRequired = courseCreditPoints - creditPointTotal;
                string courseAverage = calculateCourseAverage(creditTimesMarks, creditPointTotal);
                string courseStatus = checkCourseStatus(creditPointTotal, courseCreditPoints, failedUnits, unitAttempts);
                %>
                <!-- Display Student Data. -->
                <div class= "studentDetails">
                    <h4><table align="center"><tr>
                        <td><strong>Student ID:</strong></td>
                        <td> <% Response.Write(studentID);%></br></td></tr>
                        <tr>
                            <td><strong>Student Name: &nbsp;</strong></td>
                            <td><% Response.Write(firstName + " " + surname);%></br></td></tr>
                        <tr>
                            <td><strong>Course Type: </strong></td>
                            <td><% Response.Write(courseType); %></br></td></tr>
                        </table>
                    </h4></div>

                <!-- Display Progress Details -->
                <div class="progressDetails'">
                    <table width="430" align="center">
                        <tr><td width="400">Credit Points Required: </td>
                            <td width="500"><%Response.Write(courseCreditPoints);%></td></tr>
                        <tr><td>Total Passed Credit Points: </td>
                            <td><%Response.Write(creditPointTotal); %></td></tr>
                        <tr><td>No. of Units Attempted: </td>
                            <td><%Response.Write(unitsAttempted); %></td></tr>
                        <tr><td>No. of Units Successfully Completed: &nbsp; </td>
                            <td><%Response.Write(unitsSuccessfullyCompleted); %></td></tr>
                        <tr><td>&nbsp;</td><td>&nbsp;</td></tr><tr>
                            <td>Course Average:&nbsp; </td>
                            <td><%Response.Write(courseAverage); %></td></tr>
                        <tr><td>Course Status:&nbsp; </td>
                            <td width="500"><% Response.Write(courseStatus); %></td></tr>
                    </table>
                </div>

           <% }%>
    </main>
</body>
</html>