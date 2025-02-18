using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040TrainingInductionMaster
{
    public decimal TrainingInductionId { get; set; }

    public decimal CmpId { get; set; }

    public decimal DeptId { get; set; }

    public decimal TrainingId { get; set; }

    public string? ContactPersonId { get; set; }

    public string DeptName { get; set; } = null!;

    public string? TrainingName { get; set; }

    public string? EmpName { get; set; }
}
