using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimFamilyDetail
{
    public int ClaimMainId { get; set; }

    public int? ClaimFamilyMemberId { get; set; }

    public int? ClaimAppId { get; set; }

    public int? ClaimId { get; set; }

    public int? ClaimEmpId { get; set; }

    public string? ClaimFamilyMemberName { get; set; }

    public string? ClaimFamilyRelation { get; set; }

    public double? ClaimAge { get; set; }

    public double? ClaimLimit { get; set; }

    public double? ClaimAmount { get; set; }

    public DateTime? CfBirthDate { get; set; }

    public string? CfBillNumber { get; set; }

    public DateTime? CfBillDate { get; set; }

    public double? CfBillAmount { get; set; }
}
