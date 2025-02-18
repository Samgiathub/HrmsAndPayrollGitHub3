using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0500MutualFund
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? TrnDate { get; set; }

    public string? EmpCode { get; set; }

    public string? ClientCode { get; set; }

    public decimal? NoOfSip { get; set; }

    public decimal? SipAum { get; set; }

    public decimal? NoOfLumsum { get; set; }

    public decimal? LumsumAum { get; set; }

    public decimal? TotalNo { get; set; }

    public decimal? TotalAum { get; set; }

    public decimal? Income { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? ModifyDate { get; set; }
}
