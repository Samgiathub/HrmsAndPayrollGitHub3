using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050LeaveCfSlab
{
    public decimal SlabId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? LeaveId { get; set; }

    public decimal? FromDays { get; set; }

    public decimal? ToDays { get; set; }

    public decimal? CfDays { get; set; }

    public string? SlabFlag { get; set; }
}
