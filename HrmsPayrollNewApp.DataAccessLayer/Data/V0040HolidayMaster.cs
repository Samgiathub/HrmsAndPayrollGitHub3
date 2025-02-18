using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040HolidayMaster
{
    public decimal HdayId { get; set; }

    public decimal CmpId { get; set; }

    public string HdayName { get; set; } = null!;

    public string? HFromDate { get; set; }

    public string? HToDate { get; set; }

    public string IsFix { get; set; } = null!;

    public decimal HdayOtSetting { get; set; }

    public decimal? BranchId { get; set; }

    public byte? BranchCode { get; set; }

    public string BranchName { get; set; } = null!;

    public byte? IsOptional { get; set; }

    public string IsNationalHoliday { get; set; } = null!;

    public string IsOptional1 { get; set; } = null!;

    public DateTime HFromDate1 { get; set; }

    public DateTime HToDate1 { get; set; }
}
