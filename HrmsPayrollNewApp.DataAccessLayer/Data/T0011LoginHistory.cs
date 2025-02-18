using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011LoginHistory
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime LoginDate { get; set; }

    public string IpAddress { get; set; } = null!;

    public string? InterNetIp { get; set; }

    public string? MacAddress { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Login Login { get; set; } = null!;
}
