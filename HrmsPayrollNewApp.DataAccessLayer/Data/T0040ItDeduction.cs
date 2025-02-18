using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ItDeduction
{
    public decimal ItTranId { get; set; }

    public decimal CmpId { get; set; }

    public string ItName { get; set; } = null!;

    public decimal? MaxLimit { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
