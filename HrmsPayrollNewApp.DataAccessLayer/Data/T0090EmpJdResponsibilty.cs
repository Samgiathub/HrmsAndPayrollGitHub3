using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpJdResponsibilty
{
    public decimal EmpJdTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal JdcodeId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public string? Responsibilty { get; set; }

    public DateTime CreateDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0050JobDescriptionMaster Jdcode { get; set; } = null!;
}
