using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052BscAlertSetting
{
    public decimal BscAlertId { get; set; }

    public decimal CmpId { get; set; }

    public int? BscAlertType { get; set; }

    public decimal? BscAlertDay { get; set; }

    public decimal? BscMonth { get; set; }

    public string? BscAlertNodays { get; set; }

    public DateTime? BscDate { get; set; }

    public int? BscReviewType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
