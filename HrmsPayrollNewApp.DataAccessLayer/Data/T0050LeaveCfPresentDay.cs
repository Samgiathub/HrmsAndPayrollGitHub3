using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050LeaveCfPresentDay
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? LeaveId { get; set; }

    public decimal? PresentDay { get; set; }

    public decimal? LeaveAgainPresentDay { get; set; }

    public decimal PresentDayMaxLimit { get; set; }

    public decimal AboveMaxLimitPDays { get; set; }

    public decimal AboveMaxLimitLeaveDays { get; set; }
}
