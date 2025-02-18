using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500Expenss
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public string? BmCode { get; set; }

    public decimal? HrCost { get; set; }

    public decimal? FixedCost { get; set; }

    public decimal? NonOptExp { get; set; }

    public decimal? VariableExp { get; set; }

    public decimal? TotalExp { get; set; }

    public decimal? AllocationCost { get; set; }

    public decimal? TotalCost { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? ModifyDate { get; set; }
}
