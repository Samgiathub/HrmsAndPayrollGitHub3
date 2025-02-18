using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080EmpMasterEssApproval
{
    public int Eaid { get; set; }

    public int? EmpId { get; set; }

    public string? EmpFavSportId { get; set; }

    public string? EmpFavSportName { get; set; }

    public string? EmpHobbyId { get; set; }

    public string? EmpHobbyName { get; set; }

    public string? EmpFavFood { get; set; }

    public string? EmpFavRestro { get; set; }

    public string? EmpFavTrvDestination { get; set; }

    public string? EmpFavFestival { get; set; }

    public string? EmpFavSportPerson { get; set; }

    public string? EmpFavSinger { get; set; }

    public DateTime? Cdtm { get; set; }

    public DateTime? Udtm { get; set; }

    public int? LogDt { get; set; }

    public int? IsApproved { get; set; }

    public int? CmpId { get; set; }
}
