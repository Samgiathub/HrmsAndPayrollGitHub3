using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpChildranDetailClone
{
    public decimal EmpId { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public string Name { get; set; } = null!;

    public string Gender { get; set; } = null!;

    public DateTime? DateOfBirth { get; set; }

    public decimal? CAge { get; set; }

    public string? Relationship { get; set; }

    public decimal? IsResi { get; set; }

    public byte? IsDependant { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal LoginId { get; set; }

    public string? ImagePath { get; set; }

    public int? OccupationId { get; set; }

    public string? HobbyId { get; set; }

    public string? HobbyName { get; set; }

    public string? DepCompanyName { get; set; }

    public int? StandardId { get; set; }

    public string? ShcoolCollege { get; set; }

    public string? ExtraActivity { get; set; }

    public string? City { get; set; }

    public DateTime? Cdtm { get; set; }

    public string? CmpCity { get; set; }

    public string? StdSpecialization { get; set; }

    public string? DepWorkTime { get; set; }
}
