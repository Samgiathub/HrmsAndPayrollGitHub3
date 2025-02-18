using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095ReimOpening
{
    public decimal ReimOpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RcId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? ReimOpeningAmount { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0050AdMaster Rc { get; set; } = null!;
}
