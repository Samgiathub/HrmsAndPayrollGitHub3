using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class PresentDatum
{
    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? DurationInSec { get; set; }

    public decimal? ShiftId { get; set; }

    public decimal? ShiftType { get; set; }

    public decimal? EmpOt { get; set; }

    public decimal? EmpOtMinLimit { get; set; }

    public decimal? EmpOtMaxLimit { get; set; }

    public decimal? PDays { get; set; }

    public decimal? OtSec { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? ShiftStartTime { get; set; }

    public decimal? OtStartTime { get; set; }

    public byte? ShiftChange { get; set; }

    public int? Flag { get; set; }

    public decimal? WeekoffOtSec { get; set; }

    public decimal? HolidayOtSec { get; set; }

    public decimal? ChkBySuperior { get; set; }

    public decimal? IoTranId { get; set; }

    public DateTime? OutTime { get; set; }

    public DateTime? ShiftEndTime { get; set; }

    public decimal? OtEndTime { get; set; }

    public byte? WorkingHrsStTime { get; set; }

    public byte? WorkingHrsEndTime { get; set; }

    public decimal? GatePassDeductDays { get; set; }
}
