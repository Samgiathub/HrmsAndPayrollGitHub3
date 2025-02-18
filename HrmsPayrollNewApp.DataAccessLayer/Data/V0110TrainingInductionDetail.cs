using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110TrainingInductionDetail
{
    public decimal EmpId { get; set; }

    public DateTime TrainingDate { get; set; }

    public string TrainingTime { get; set; } = null!;

    public decimal TrainingInductionId { get; set; }

    public decimal TrainingId { get; set; }

    public string DeptName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string? ContactPerson { get; set; }

    public string? ContactPersonId { get; set; }

    public string? TrainingName { get; set; }
}
