using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095EmpScheme
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal SchemeId { get; set; }

    public string Type { get; set; } = null!;

    public DateTime EffectiveDate { get; set; }

    public bool? IsMakerChecker { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040SchemeMaster Scheme { get; set; } = null!;
}
