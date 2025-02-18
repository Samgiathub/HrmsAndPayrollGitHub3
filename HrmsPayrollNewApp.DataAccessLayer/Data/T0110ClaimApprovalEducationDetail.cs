using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimApprovalEducationDetail
{
    public int CaedId { get; set; }

    public int? CaedClaimAppId { get; set; }

    public int? CaedEmpId { get; set; }

    public int? CaedRowId { get; set; }

    public string? CaedName { get; set; }

    public int? CaedRelationId { get; set; }

    public string? CaedRelationName { get; set; }

    public string? CaedSchoolCollegeName { get; set; }

    public string? CaedClassName { get; set; }

    public string? CaedEducatinLevel { get; set; }

    public double? CaedRequestedAmount { get; set; }

    public int? CaedQuarterId { get; set; }

    public string? CaedQuarter { get; set; }
}
