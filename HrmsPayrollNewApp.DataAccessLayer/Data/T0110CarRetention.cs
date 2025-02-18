using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110CarRetention
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? AdId { get; set; }

    public decimal? AdAmount { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public DateTime? SysDateTime { get; set; }

    public string? LoginId { get; set; }

    public decimal NoOfMonth { get; set; }
}
