using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TrainingInductionMaster
{
    public decimal TrainingInductionId { get; set; }

    public decimal CmpId { get; set; }

    public decimal DeptId { get; set; }

    public decimal TrainingId { get; set; }

    public string? ContactPersonId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DepartmentMaster Dept { get; set; } = null!;

    public virtual ICollection<T0110TrainingInductionDetail> T0110TrainingInductionDetails { get; set; } = new List<T0110TrainingInductionDetail>();

    public virtual T0040HrmsTrainingMaster Training { get; set; } = null!;
}
