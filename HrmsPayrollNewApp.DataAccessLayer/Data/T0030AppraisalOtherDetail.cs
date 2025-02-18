using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030AppraisalOtherDetail
{
    public decimal AoId { get; set; }

    public decimal CmpId { get; set; }

    public string? Action { get; set; }

    public int? DesigRequired { get; set; }

    public int? FromDateRequired { get; set; }

    public int? ToDateRequired { get; set; }

    public int? Active { get; set; }
}
