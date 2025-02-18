using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250Form16PublishEss
{
    public decimal PublishId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string FinancialYear { get; set; } = null!;

    public byte IsPublish { get; set; }

    public DateTime SystemDate { get; set; }

    public string? Comments { get; set; }
}
