using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0030BranchMaster
{
    public string? BranchName { get; set; }

    public string? BranchAddress { get; set; }

    public string? BranchCity { get; set; }

    public string? StateName { get; set; }

    public decimal BranchId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? StateId { get; set; }

    public string? BranchCode { get; set; }

    public string? CompName { get; set; }

    public byte IsContractorBranch { get; set; }

    public decimal? BranchDefault { get; set; }

    public string CmpName { get; set; } = null!;

    public decimal? LocationId { get; set; }

    public string? LocName { get; set; }

    public int? DistrictId { get; set; }

    public string? DistName { get; set; }

    public int? TehsilId { get; set; }

    public string? TName { get; set; }

    public string? PtRcNo { get; set; }

    public string? PtZone { get; set; }

    public string? PtWardNo { get; set; }

    public string? PtCensusNo { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public string? PfNo { get; set; }

    public string? EsicNo { get; set; }

    public string StatusColor { get; set; } = null!;

    public string? ContrPersonName { get; set; }

    public string? ContrEmail { get; set; }

    public string? ContrMobileNo { get; set; }

    public string? ContrAadhaar { get; set; }

    public string? ContrGstnumber { get; set; }

    public string? NatureOfWork { get; set; }

    public decimal? NoOfLabourEmployed { get; set; }

    public DateTime? DateOfCommencement { get; set; }

    public DateTime? DateOfTermination { get; set; }

    public string? VendorCode { get; set; }

    public decimal? ContrDetId { get; set; }

    public string? LicenceDoc { get; set; }
}
