using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110EmployeeTrainingIdentification
{
    public decimal EmpTrainingId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TrainingId { get; set; }

    public string TrainingYear { get; set; } = null!;
}
