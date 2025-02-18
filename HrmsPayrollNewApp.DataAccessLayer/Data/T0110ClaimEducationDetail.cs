using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimEducationDetail
{
    public int CedId { get; set; }

    public int? CedClaimAppId { get; set; }

    public int? CedEmpId { get; set; }

    public int? CedRowId { get; set; }

    public string? CedName { get; set; }

    public int? CedRelationId { get; set; }

    public string? CedRelationName { get; set; }

    public string? CedSchoolCollegeName { get; set; }

    public string? CedClassName { get; set; }

    public string? CedEducatinLevel { get; set; }

    public double? CedRequestedAmount { get; set; }

    public int? CedQuarterId { get; set; }

    public string? CedQuarter { get; set; }
}
