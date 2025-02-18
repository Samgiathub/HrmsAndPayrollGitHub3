using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130LtaForDependant
{
    public decimal LtaDId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LmAppId { get; set; }

    public decimal? DependId { get; set; }

    public int? Age { get; set; }

    public decimal? LmAprId { get; set; }

    public decimal? EmpId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0110LtaMedicalApplication LmApp { get; set; } = null!;

    public virtual T0120LtaMedicalApproval? LmApr { get; set; }
}
