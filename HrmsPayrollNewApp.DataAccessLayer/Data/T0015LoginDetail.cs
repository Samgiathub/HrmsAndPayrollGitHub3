using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0015LoginDetail
{
    public decimal LoginId { get; set; }

    public decimal CmpId { get; set; }

    public string IpAddress { get; set; } = null!;

    public DateTime SysDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Login Login { get; set; } = null!;
}
