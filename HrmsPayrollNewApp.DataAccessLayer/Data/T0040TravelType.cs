using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TravelType
{
    public decimal TravelTypeId { get; set; }

    public string? TravelTypeName { get; set; }

    public string? TravelTypeDescription { get; set; }

    public decimal? TravelTypeSorting { get; set; }

    public decimal? DefualtState { get; set; }

    public decimal? CmpId { get; set; }
}
