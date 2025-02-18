using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040RatingMaster
{
    public decimal RatingId { get; set; }

    public decimal CmpId { get; set; }

    public string Title { get; set; } = null!;

    public string Description { get; set; } = null!;

    public decimal FromRate { get; set; }

    public decimal ToRate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
