using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050RouteVehicleDetail
{
    public decimal? AssignId { get; set; }

    public decimal VehicleId { get; set; }

    public decimal? RouteId { get; set; }

    public string? EffectiveDate { get; set; }

    public string? RouteName { get; set; }

    public string? VehicleName { get; set; }

    public string? VehicleNo { get; set; }

    public decimal? CmpId { get; set; }

    public string? VehicleOwner { get; set; }

    public string? RouteNo { get; set; }

    public decimal? RouteKm { get; set; }

    public string? OwnerName { get; set; }

    public string? OwnerContactNo { get; set; }

    public string? DriverName { get; set; }

    public string? DriverContactNo { get; set; }
}
