using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HolidayMaster
{
    public decimal HdayId { get; set; }

    public decimal CmpId { get; set; }

    public string HdayName { get; set; } = null!;

    public DateTime HFromDate { get; set; }

    public DateTime HToDate { get; set; }

    public string IsFix { get; set; } = null!;

    public decimal HdayOtSetting { get; set; }

    public decimal? BranchId { get; set; }

    public byte? IsHalf { get; set; }

    public byte? IsPComp { get; set; }

    public string? MessageText { get; set; }

    public int? Sms { get; set; }

    public int? NoOfHoliday { get; set; }

    public DateTime? SystemDate { get; set; }

    public byte IsNationalHoliday { get; set; }

    public byte? IsOptional { get; set; }

    public byte MultipleHoliday { get; set; }

    public byte IsUnpaidHoliday { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0050OptionalHolidayLimit> T0050OptionalHolidayLimits { get; set; } = new List<T0050OptionalHolidayLimit>();

    public virtual ICollection<T0100OpHolidayApplication> T0100OpHolidayApplications { get; set; } = new List<T0100OpHolidayApplication>();

    public virtual ICollection<T0120OpHolidayApproval> T0120OpHolidayApprovals { get; set; } = new List<T0120OpHolidayApproval>();
}
