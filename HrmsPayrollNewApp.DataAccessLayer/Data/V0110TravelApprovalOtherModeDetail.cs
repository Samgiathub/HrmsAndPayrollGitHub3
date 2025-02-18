using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110TravelApprovalOtherModeDetail
{
    public long TranId { get; set; }

    public int? CmpId { get; set; }

    public long? TravelAppOtherDetailId { get; set; }

    public long? TravelAppId { get; set; }

    public decimal? TravelMode { get; set; }

    public string? FromPlace { get; set; }

    public string? ToPlace { get; set; }

    public string? ModeName { get; set; }

    public string? ModeNo { get; set; }

    public string? City { get; set; }

    public DateTime? CheckOutDate { get; set; }

    public decimal NoPassenger { get; set; }

    public string? BookingDate { get; set; }

    public string? PickUpAddress { get; set; }

    public string? PickUpTime { get; set; }

    public string? DropAddress { get; set; }

    public string? BillNo { get; set; }

    public string? Description { get; set; }
}
