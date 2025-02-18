using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110TrainingInductionDetail
{
    public decimal TranId { get; set; }

    public decimal TrainingInductionId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime TrainingDate { get; set; }

    public DateTime TrainingTime { get; set; }

    public decimal ModifyBy { get; set; }

    public DateTime ModifyDate { get; set; }

    public string IpAddress { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040TrainingInductionMaster TrainingInduction { get; set; } = null!;
}
