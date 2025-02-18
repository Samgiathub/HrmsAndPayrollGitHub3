using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040EmployeeTransportRegistration
{
    public decimal TransportRegId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? RouteId { get; set; }

    public decimal? PickupId { get; set; }

    public decimal? DesignationId { get; set; }

    public int? TransportStatus { get; set; }

    public string? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }

    public string? RouteName { get; set; }

    public string? PickupName { get; set; }

    public string? DesignationName { get; set; }

    public string? EmpName { get; set; }

    public decimal EmpCode { get; set; }

    public string TransStatus { get; set; } = null!;

    public string TransType { get; set; } = null!;

    public string? TransportType { get; set; }
}
