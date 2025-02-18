using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class EmpFnfAllowanceDetail
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal? FnfId { get; set; }

    public decimal CmpId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
