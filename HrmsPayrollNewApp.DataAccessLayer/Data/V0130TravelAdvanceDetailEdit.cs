using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130TravelAdvanceDetailEdit
{
    public decimal TravelAdvanceDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TravelAppId { get; set; }

    public string ExpenceType { get; set; } = null!;

    public decimal Amount { get; set; }

    public string? AdvDetailDesc { get; set; }

    public decimal CurrId { get; set; }

    public string Currency { get; set; } = null!;
}
