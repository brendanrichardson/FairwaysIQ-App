import AsyncStorage from "@react-native-async-storage/async-storage";
import * as Location from "expo-location";
import React, { useEffect, useMemo, useRef, useState } from "react";
import {
  Alert,
  Modal,
  Platform,
  Pressable,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  View,
} from "react-native";
import MapView, { Circle, Marker, Polygon, Polyline } from "react-native-maps";

const STORAGE_KEY = "fairway-iq-expo-user-data";

const CLUB_TYPES = [
  "Driver",
  "2 Wood",
  "3 Wood",
  "4 Wood",
  "5 Wood",
  "7 Wood",
  "9 Wood",
  "2 Hybrid",
  "3 Hybrid",
  "4 Hybrid",
  "5 Hybrid",
  "6 Hybrid",
  "1 Iron",
  "2 Iron",
  "3 Iron",
  "4 Iron",
  "5 Iron",
  "6 Iron",
  "7 Iron",
  "8 Iron",
  "9 Iron",
  "Pitching Wedge",
  "Gap Wedge",
  "Sand Wedge",
  "Lob Wedge",
  "Chipper",
  "Putter",
];

const BRANDS = [
  "Callaway",
  "TaylorMade",
  "Titleist",
  "PING",
  "Cobra",
  "Mizuno",
  "Srixon",
  "Cleveland",
  "Wilson",
  "PXG",
  "Tour Edge",
  "Ben Hogan",
  "Odyssey",
  "Scotty Cameron",
  "Bettinardi",
  "Evnroll",
  "L.A.B. Golf",
  "Sub 70",
  "Maltby",
  "Other",
];

const LIES = ["Tee", "Fairway", "First cut", "Rough", "Sand"];
const TARGETS = ["Green", "Fairway"];

const COURSE_INFO = {
  name: "Harry L. Jones Sr. Public Golf Course",
  mappedName: "Renaissance Park Golf Course",
  address: "1525 West Tyvola Road, Charlotte, NC 28217",
  center: { latitude: 35.1721185, longitude: -80.9127536 },
};

const DEMO_HOLES = [
  {
    id: 1,
    number: 1,
    par: 5,
    handicap: 1,
    mappedYards: 551,
    tee: { latitude: 35.1735606, longitude: -80.9093577 },
    fairwayCenter: { latitude: 35.1716404, longitude: -80.9079173 },
    greenCenter: { latitude: 35.1697201, longitude: -80.9064768 },
    hazards: [],
  },
  {
    id: 2,
    number: 2,
    par: 4,
    handicap: 3,
    mappedYards: 397,
    tee: { latitude: 35.1693377, longitude: -80.9057622 },
    fairwayCenter: { latitude: 35.1684239, longitude: -80.9073977 },
    greenCenter: { latitude: 35.1675101, longitude: -80.9090332 },
    hazards: [],
  },
  {
    id: 3,
    number: 3,
    par: 3,
    handicap: 17,
    mappedYards: 159,
    tee: { latitude: 35.1671977, longitude: -80.9095734 },
    fairwayCenter: { latitude: 35.1670929, longitude: -80.9103642 },
    greenCenter: { latitude: 35.166988, longitude: -80.9111551 },
    hazards: [],
  },
  {
    id: 4,
    number: 4,
    par: 5,
    handicap: 13,
    mappedYards: 464,
    tee: { latitude: 35.1671776, longitude: -80.9122398 },
    fairwayCenter: { latitude: 35.1686596, longitude: -80.9136787 },
    greenCenter: { latitude: 35.1701415, longitude: -80.9151175 },
    hazards: [],
  },
  {
    id: 5,
    number: 5,
    par: 3,
    handicap: 9,
    mappedYards: 189,
    tee: { latitude: 35.1707569, longitude: -80.915494 },
    fairwayCenter: { latitude: 35.1714153, longitude: -80.9150153 },
    greenCenter: { latitude: 35.1720737, longitude: -80.9145365 },
    hazards: [],
  },
  {
    id: 6,
    number: 6,
    par: 4,
    handicap: 5,
    mappedYards: 381,
    tee: { latitude: 35.1723525, longitude: -80.9137841 },
    fairwayCenter: { latitude: 35.1709634, longitude: -80.913672 },
    greenCenter: { latitude: 35.1695742, longitude: -80.9135598 },
    hazards: [],
  },
  {
    id: 7,
    number: 7,
    par: 4,
    handicap: 7,
    mappedYards: 403,
    tee: { latitude: 35.1699539, longitude: -80.912954 },
    fairwayCenter: { latitude: 35.168767, longitude: -80.9117962 },
    greenCenter: { latitude: 35.1675801, longitude: -80.9106384 },
    hazards: [],
  },
  {
    id: 8,
    number: 8,
    par: 4,
    handicap: 11,
    mappedYards: 260,
    tee: { latitude: 35.1683808, longitude: -80.9088552 },
    fairwayCenter: { latitude: 35.1693599, longitude: -80.9084225 },
    greenCenter: { latitude: 35.1703391, longitude: -80.9079898 },
    hazards: [],
  },
  {
    id: 9,
    number: 9,
    par: 4,
    handicap: 15,
    mappedYards: 334,
    tee: { latitude: 35.1711759, longitude: -80.9085125 },
    fairwayCenter: { latitude: 35.1721482, longitude: -80.9096804 },
    greenCenter: { latitude: 35.1731205, longitude: -80.9108483 },
    hazards: [],
  },
  {
    id: 10,
    number: 10,
    par: 4,
    handicap: 16,
    mappedYards: 352,
    tee: { latitude: 35.1739601, longitude: -80.912023 },
    fairwayCenter: { latitude: 35.1738693, longitude: -80.9137794 },
    greenCenter: { latitude: 35.1737785, longitude: -80.9155357 },
    hazards: [],
  },
  {
    id: 11,
    number: 11,
    par: 3,
    handicap: 18,
    mappedYards: 120,
    tee: { latitude: 35.1740447, longitude: -80.9164908 },
    fairwayCenter: { latitude: 35.1739715, longitude: -80.9170856 },
    greenCenter: { latitude: 35.1738983, longitude: -80.9176804 },
    hazards: [],
  },
  {
    id: 12,
    number: 12,
    par: 4,
    handicap: 6,
    mappedYards: 390,
    tee: { latitude: 35.1746251, longitude: -80.918175 },
    fairwayCenter: { latitude: 35.1761343, longitude: -80.918414 },
    greenCenter: { latitude: 35.1776436, longitude: -80.9186529 },
    hazards: [],
  },
  {
    id: 13,
    number: 13,
    par: 3,
    handicap: 14,
    mappedYards: 205,
    tee: { latitude: 35.1780255, longitude: -80.9174051 },
    fairwayCenter: { latitude: 35.1788021, longitude: -80.9170183 },
    greenCenter: { latitude: 35.1795787, longitude: -80.9166315 },
    hazards: [],
  },
  {
    id: 14,
    number: 14,
    par: 5,
    handicap: 10,
    mappedYards: 523,
    tee: { latitude: 35.1791801, longitude: -80.9150551 },
    fairwayCenter: { latitude: 35.1773564, longitude: -80.9164223 },
    greenCenter: { latitude: 35.1755326, longitude: -80.9177894 },
    hazards: [],
  },
  {
    id: 15,
    number: 15,
    par: 4,
    handicap: 2,
    mappedYards: 363,
    tee: { latitude: 35.1758253, longitude: -80.9164792 },
    fairwayCenter: { latitude: 35.1771156, longitude: -80.9155794 },
    greenCenter: { latitude: 35.1784059, longitude: -80.9146796 },
    hazards: [],
  },
  {
    id: 16,
    number: 16,
    par: 5,
    handicap: 8,
    mappedYards: 480,
    tee: { latitude: 35.1789811, longitude: -80.9142899 },
    fairwayCenter: { latitude: 35.177232, longitude: -80.9146639 },
    greenCenter: { latitude: 35.1754829, longitude: -80.9150378 },
    hazards: [],
  },
  {
    id: 17,
    number: 17,
    par: 4,
    handicap: 12,
    mappedYards: 339,
    tee: { latitude: 35.1757326, longitude: -80.9137379 },
    fairwayCenter: { latitude: 35.177066, longitude: -80.913633 },
    greenCenter: { latitude: 35.1783993, longitude: -80.9135281 },
    hazards: [],
  },
  {
    id: 18,
    number: 18,
    par: 4,
    handicap: 4,
    mappedYards: 395,
    tee: { latitude: 35.1784936, longitude: -80.9129908 },
    fairwayCenter: { latitude: 35.1770225, longitude: -80.9126583 },
    greenCenter: { latitude: 35.1755513, longitude: -80.9123258 },
    hazards: [],
  },
];

const EMPTY_PROFILE = {
  name: "",
  handicap: "",
  homeCourse: "",
  preferredTee: "",
  dominantMiss: "",
  notes: "",
};

const STARTER_CLUBS = [
  makeClub("Driver", "Titleist", "TSR", 10.5, 245, 265, 24, 32, 16, 18),
  makeClub("3 Wood", "TaylorMade", "Fairway", 15, 218, 235, 20, 25, 14, 15),
  makeClub("4 Hybrid", "PING", "Hybrid", 22, 195, 205, 16, 19, 11, 12),
  makeClub("6 Iron", "Mizuno", "Iron", 28, 168, 174, 13, 15, 9, 10),
  makeClub("8 Iron", "Mizuno", "Iron", 36, 142, 147, 10, 12, 8, 8),
  makeClub("Pitching Wedge", "Cleveland", "Wedge", 46, 118, 121, 8, 9, 7, 7),
  makeClub("Sand Wedge", "Cleveland", "Wedge", 56, 82, 84, 6, 7, 6, 5),
];

function makeClub(type, brand, model, loft, carry, total, left, right, short, long) {
  return {
    id: `${Date.now()}-${Math.random().toString(16).slice(2)}`,
    name: type,
    type,
    category: categoryForType(type),
    brand,
    model,
    shaft: "",
    loftDegrees: loft ? String(loft) : "",
    carryYards: String(carry),
    totalYards: String(total),
    leftMissYards: String(left),
    rightMissYards: String(right),
    shortMissYards: String(short),
    longMissYards: String(long),
  };
}

function defaultClub(type = "7 Iron", brand = "Other") {
  const carry = defaultCarry(type);
  const total = categoryForType(type) === "Wedge" || type === "Putter" ? carry + 2 : carry + 8;
  const lateral = { Driver: 30, Wood: 24, Hybrid: 19, Iron: 14, Wedge: 8, Putter: 2 }[categoryForType(type)];
  const depth = { Driver: 18, Wood: 15, Hybrid: 12, Iron: 9, Wedge: 6, Putter: 2 }[categoryForType(type)];
  return makeClub(type, brand, "", defaultLoft(type), carry, total, lateral, lateral, depth, depth);
}

export default function App() {
  const mapRef = useRef(null);
  const [userData, setUserData] = useState({ profile: EMPTY_PROFILE, clubs: STARTER_CLUBS });
  const [selectedHoleIndex, setSelectedHoleIndex] = useState(0);
  const [targetMode, setTargetMode] = useState("Green");
  const [customTarget, setCustomTarget] = useState(null);
  const [lie, setLie] = useState("Fairway");
  const [wind, setWind] = useState(0);
  const [elevation, setElevation] = useState(0);
  const [location, setLocation] = useState(null);
  const [bagOpen, setBagOpen] = useState(false);
  const [profileOpen, setProfileOpen] = useState(false);
  const [clubOpen, setClubOpen] = useState(null);
  const [hydrated, setHydrated] = useState(false);

  const hole = DEMO_HOLES[selectedHoleIndex];
  const ballLocation = location || hole.tee;
  const defaultTarget = targetMode === "Green" ? hole.greenCenter : hole.fairwayCenter;
  const target = customTarget || defaultTarget;

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY).then((raw) => {
      if (raw) setUserData(JSON.parse(raw));
      setHydrated(true);
    }).catch(() => {
      setHydrated(true);
    });
  }, []);

  useEffect(() => {
    if (!hydrated) return;
    AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(userData));
  }, [hydrated, userData]);

  const recommendations = useMemo(
    () => recommend({ ballLocation, target, hole, lie, wind, elevation }, userData.clubs),
    [ballLocation, target, hole, lie, wind, elevation, userData.clubs]
  );

  const topPick = recommendations[0];
  const dispersionShape = useMemo(
    () => (topPick ? dispersionPolygon(ballLocation, target, topPick) : []),
    [ballLocation, target, topPick]
  );
  const distanceToTarget = distanceYards(ballLocation, target);
  const fromTee = distanceYards(hole.tee, ballLocation) / 100;
  const holeDistance = hole.mappedYards || distanceYards(hole.tee, hole.greenCenter);

  useEffect(() => {
    setCustomTarget(null);
    mapRef.current?.animateToRegion(
      {
        latitude: hole.fairwayCenter.latitude,
        longitude: hole.fairwayCenter.longitude,
        latitudeDelta: 0.0042,
        longitudeDelta: 0.0032,
      },
      450
    );
  }, [hole.id]);

  useEffect(() => {
    setCustomTarget(null);
  }, [targetMode]);

  async function requestGps() {
    const { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== "granted") {
      Alert.alert("Location needed", "Enable location access to use live GPS yardages.");
      return;
    }
    const current = await Location.getCurrentPositionAsync({ accuracy: Location.Accuracy.High });
    setLocation({ latitude: current.coords.latitude, longitude: current.coords.longitude });
  }

  function updateProfile(profile) {
    setUserData((current) => ({ ...current, profile }));
  }

  function updateClub(updatedClub) {
    setUserData((current) => ({
      ...current,
      clubs: current.clubs
        .map((club) => (club.id === updatedClub.id ? { ...updatedClub, category: categoryForType(updatedClub.type) } : club))
        .sort((a, b) => numberValue(b.totalYards) - numberValue(a.totalYards)),
    }));
  }

  function addClub(type) {
    setUserData((current) => ({ ...current, clubs: [...current.clubs, defaultClub(type)].sort((a, b) => numberValue(b.totalYards) - numberValue(a.totalYards)) }));
  }

  return (
    <View style={styles.screen}>
      <StatusBar barStyle="light-content" />
      <MapView
        ref={mapRef}
        style={StyleSheet.absoluteFill}
        mapType="satellite"
        showsUserLocation
        pitchEnabled
        rotateEnabled
        scrollEnabled
        zoomEnabled
        onPress={(event) => setCustomTarget(event.nativeEvent.coordinate)}
        initialRegion={{
          latitude: hole.fairwayCenter.latitude,
          longitude: hole.fairwayCenter.longitude,
          latitudeDelta: 0.0042,
          longitudeDelta: 0.0032,
        }}
      >
        <Polyline coordinates={[hole.tee, hole.fairwayCenter, hole.greenCenter]} strokeColor="rgba(255,255,255,0.5)" strokeWidth={2} lineDashPattern={[6, 6]} />
        <Polyline coordinates={[ballLocation, target]} strokeColor="rgba(0,0,0,0.45)" strokeWidth={7} />
        <Polyline coordinates={[ballLocation, target]} strokeColor="white" strokeWidth={3} lineDashPattern={[9, 6]} />
        {dispersionShape.length > 0 && (
          <Polygon
            coordinates={dispersionShape}
            fillColor="rgba(96,233,128,0.22)"
            strokeColor="rgba(255,255,255,0.9)"
            strokeWidth={2}
          />
        )}
        {hole.hazards.map((hazard) => (
          <Circle
            key={hazard.id}
            center={hazard.coordinate}
            radius={hazard.radiusYards * 0.9144}
            fillColor={hazardColor(hazard.kind, 0.38)}
            strokeColor="rgba(255,255,255,0.85)"
            strokeWidth={1}
          />
        ))}
        <Marker coordinate={ballLocation} anchor={{ x: 0.5, y: 0.5 }}>
          <View style={styles.ballMarker}><View style={styles.ballDot} /></View>
        </Marker>
        <Marker
          coordinate={target}
          anchor={{ x: 0.5, y: 0.5 }}
          draggable
          onDragEnd={(event) => setCustomTarget(event.nativeEvent.coordinate)}
        >
          <View style={[styles.targetMarker, targetMode === "Green" && styles.greenMarker]}>
            <View style={styles.targetDot}><Text style={styles.targetIcon}>{targetMode === "Green" ? "⚑" : "⌖"}</Text></View>
          </View>
        </Marker>
      </MapView>

      <View pointerEvents="none" style={styles.vignette} />

      <SafeAreaView style={styles.overlay} pointerEvents="box-none">
        <View style={styles.topRow} pointerEvents="box-none">
          <MetricBubble title="To Hole" value={`${Math.round(distanceToTarget)} yd`} />
          <MetricBubble title="From Tee" value={fromTee.toFixed(2)} />
        </View>

        <View style={styles.centerReadout} pointerEvents="box-none">
          <Text style={styles.mainYardage}>{Math.round(distanceToTarget)} yd</Text>
          {topPick && (
            <>
              <Text style={styles.confidence}>+ {topPick.confidence.toFixed(2)} ({targetMode === "Green" ? "GRN" : "FWY"})</Text>
              <View style={styles.badgeRow}>
                <Text style={styles.miniBadge}>{topPick.name}</Text>
                <Text style={styles.miniBadge}>{Math.round(numberValue(topPick.carryYards))} carry</Text>
              </View>
              <Text style={styles.dragHint}>Tap map or drag target</Text>
            </>
          )}
        </View>

        <View style={styles.sideArea} pointerEvents="box-none">
          <View style={styles.leftRail}>
            <RailButton label="Bag" onPress={() => setBagOpen(true)} />
            <RailButton label="GPS" onPress={requestGps} />
            <RailButton label="Aim" />
            <RailButton label="Lie" />
          </View>

          <View style={styles.rightRail}>
            <Pressable style={styles.windPill} onPress={() => setWind((value) => (value >= 25 ? -25 : value + 1))}>
              <Text style={styles.windArrow}>{wind >= 0 ? "↑" : "↓"}</Text>
              <Text style={styles.windText}>{Math.abs(wind)} mph</Text>
              <Text style={styles.liveText}>Live</Text>
            </Pressable>
            <Segment values={TARGETS} selected={targetMode} onSelect={setTargetMode} />
            <Segment values={LIES} selected={lie} onSelect={setLie} compact />
            <Segment values={recommendations.slice(0, 4).map((club) => club.name)} selected={topPick?.name} compact />
            <Pressable style={styles.roundButton} onPress={() => setCustomTarget(null)}>
              <Text style={styles.roundButtonText}>Reset</Text>
            </Pressable>
            <Pressable style={styles.roundButton} onPress={() => setElevation((value) => (value >= 80 ? -80 : value + 5))}>
              <Text style={styles.roundButtonText}>{elevation} ft</Text>
            </Pressable>
          </View>
        </View>

        <View style={styles.bottomBar}>
          <Pressable onPress={() => setSelectedHoleIndex(Math.max(0, selectedHoleIndex - 1))}><Text style={styles.chevron}>‹</Text></Pressable>
          <View style={styles.holeLabel}>
            <Text style={styles.holeTitle}>Hole {hole.number} - Par {hole.par}</Text>
            <Text style={styles.holeSub}>{Math.round(holeDistance)} Yards</Text>
          </View>
          <Pressable onPress={() => setSelectedHoleIndex(Math.min(DEMO_HOLES.length - 1, selectedHoleIndex + 1))}><Text style={styles.chevron}>›</Text></Pressable>
        </View>
      </SafeAreaView>

      <BagModal
        visible={bagOpen}
        userData={userData}
        onClose={() => setBagOpen(false)}
        onOpenProfile={() => setProfileOpen(true)}
        onOpenClub={setClubOpen}
        onAddClub={addClub}
      />
      <ProfileModal visible={profileOpen} profile={userData.profile} onSave={updateProfile} onClose={() => setProfileOpen(false)} />
      <ClubModal visible={Boolean(clubOpen)} club={clubOpen} onSave={updateClub} onClose={() => setClubOpen(null)} />
    </View>
  );
}

function MetricBubble({ title, value }) {
  return (
    <View style={styles.metricBubble}>
      <Text style={styles.metricTitle}>{title}</Text>
      <Text style={styles.metricValue}>{value}</Text>
    </View>
  );
}

function RailButton({ label, onPress }) {
  return (
    <Pressable style={styles.railButton} onPress={onPress}>
      <Text style={styles.railText}>{label}</Text>
    </Pressable>
  );
}

function Segment({ values, selected, onSelect, compact }) {
  return (
    <View style={styles.segment}>
      {values.map((value) => (
        <Pressable key={value} onPress={() => onSelect?.(value)} style={[styles.segmentItem, compact && styles.segmentCompact, selected === value && styles.segmentSelected]}>
          <Text style={[styles.segmentText, selected === value && styles.segmentSelectedText]} numberOfLines={1}>{shortControlLabel(value)}</Text>
        </Pressable>
      ))}
    </View>
  );
}

function BagModal({ visible, userData, onClose, onOpenProfile, onOpenClub, onAddClub }) {
  const [addOpen, setAddOpen] = useState(false);
  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet">
      <SafeAreaView style={styles.modal}>
        <View style={styles.modalHeader}>
          <Text style={styles.modalTitle}>My Bag</Text>
          <Pressable onPress={onClose}><Text style={styles.doneText}>Done</Text></Pressable>
        </View>
        <ScrollView contentContainerStyle={styles.modalContent}>
          <Pressable style={styles.profileCard} onPress={onOpenProfile}>
            <Text style={styles.cardTitle}>{userData.profile.name || "Add your profile"}</Text>
            <Text style={styles.cardSub}>{profileSubtitle(userData.profile)}</Text>
          </Pressable>

          <Pressable style={styles.addButton} onPress={() => setAddOpen(!addOpen)}>
            <Text style={styles.addButtonText}>{addOpen ? "Hide Club Types" : "Add Club"}</Text>
          </Pressable>
          {addOpen && (
            <View style={styles.typeGrid}>
              {CLUB_TYPES.map((type) => (
                <Pressable key={type} style={styles.typeChip} onPress={() => onAddClub(type)}>
                  <Text style={styles.typeChipText}>{type}</Text>
                </Pressable>
              ))}
            </View>
          )}

          {userData.clubs.map((club) => (
            <Pressable key={club.id} style={styles.clubRow} onPress={() => onOpenClub(club)}>
              <View>
                <Text style={styles.clubName}>{club.name}</Text>
                <Text style={styles.clubMeta}>{club.brand} {club.model}</Text>
              </View>
              <View style={styles.clubNumbers}>
                <Text style={styles.clubCarry}>{Math.round(numberValue(club.carryYards))} carry</Text>
                <Text style={styles.clubMeta}>{Math.round(avgDispersion(club))} yd miss</Text>
              </View>
            </Pressable>
          ))}
        </ScrollView>
      </SafeAreaView>
    </Modal>
  );
}

function ProfileModal({ visible, profile, onSave, onClose }) {
  const [draft, setDraft] = useState(profile);
  useEffect(() => setDraft(profile), [profile]);
  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet">
      <EditorShell title="Golfer Profile" onClose={onClose} onSave={() => { onSave(draft); onClose(); }}>
        <Field label="Name" value={draft.name} onChangeText={(name) => setDraft({ ...draft, name })} />
        <Field label="Handicap" value={draft.handicap} keyboardType="decimal-pad" onChangeText={(handicap) => setDraft({ ...draft, handicap })} />
        <Field label="Home Course" value={draft.homeCourse} onChangeText={(homeCourse) => setDraft({ ...draft, homeCourse })} />
        <Field label="Preferred Tee" value={draft.preferredTee} onChangeText={(preferredTee) => setDraft({ ...draft, preferredTee })} />
        <Field label="Dominant Miss" value={draft.dominantMiss} onChangeText={(dominantMiss) => setDraft({ ...draft, dominantMiss })} />
        <Field label="Notes" value={draft.notes} multiline onChangeText={(notes) => setDraft({ ...draft, notes })} />
      </EditorShell>
    </Modal>
  );
}

function ClubModal({ visible, club, onSave, onClose }) {
  const [draft, setDraft] = useState(club);
  useEffect(() => setDraft(club), [club]);
  if (!draft) return null;
  return (
    <Modal visible={visible} animationType="slide" presentationStyle="pageSheet">
      <EditorShell title={draft.name || "Club"} onClose={onClose} onSave={() => { onSave(draft); onClose(); }}>
        <Field label="Display Name" value={draft.name} onChangeText={(name) => setDraft({ ...draft, name })} />
        <OptionGrid label="Type" values={CLUB_TYPES} selected={draft.type} onSelect={(type) => setDraft({ ...draft, type, category: categoryForType(type), name: type })} />
        <OptionGrid label="Brand" values={BRANDS} selected={draft.brand} onSelect={(brand) => setDraft({ ...draft, brand })} />
        <Field label="Model" value={draft.model} onChangeText={(model) => setDraft({ ...draft, model })} />
        <Field label="Shaft" value={draft.shaft} onChangeText={(shaft) => setDraft({ ...draft, shaft })} />
        <Field label="Loft" value={draft.loftDegrees} keyboardType="decimal-pad" onChangeText={(loftDegrees) => setDraft({ ...draft, loftDegrees })} />
        <Field label="Carry Yards" value={draft.carryYards} keyboardType="number-pad" onChangeText={(carryYards) => setDraft({ ...draft, carryYards })} />
        <Field label="Total Yards" value={draft.totalYards} keyboardType="number-pad" onChangeText={(totalYards) => setDraft({ ...draft, totalYards })} />
        <Field label="Left Miss" value={draft.leftMissYards} keyboardType="number-pad" onChangeText={(leftMissYards) => setDraft({ ...draft, leftMissYards })} />
        <Field label="Right Miss" value={draft.rightMissYards} keyboardType="number-pad" onChangeText={(rightMissYards) => setDraft({ ...draft, rightMissYards })} />
        <Field label="Short Miss" value={draft.shortMissYards} keyboardType="number-pad" onChangeText={(shortMissYards) => setDraft({ ...draft, shortMissYards })} />
        <Field label="Long Miss" value={draft.longMissYards} keyboardType="number-pad" onChangeText={(longMissYards) => setDraft({ ...draft, longMissYards })} />
      </EditorShell>
    </Modal>
  );
}

function EditorShell({ title, children, onClose, onSave }) {
  return (
    <SafeAreaView style={styles.modal}>
      <View style={styles.modalHeader}>
        <Pressable onPress={onClose}><Text style={styles.doneText}>Cancel</Text></Pressable>
        <Text style={styles.modalTitle}>{title}</Text>
        <Pressable onPress={onSave}><Text style={styles.doneText}>Save</Text></Pressable>
      </View>
      <ScrollView contentContainerStyle={styles.modalContent}>{children}</ScrollView>
    </SafeAreaView>
  );
}

function Field({ label, value, onChangeText, keyboardType, multiline }) {
  return (
    <View style={styles.field}>
      <Text style={styles.fieldLabel}>{label}</Text>
      <TextInput
        style={[styles.input, multiline && styles.textArea]}
        value={String(value || "")}
        onChangeText={onChangeText}
        keyboardType={keyboardType}
        multiline={multiline}
        placeholderTextColor="#777"
      />
    </View>
  );
}

function OptionGrid({ label, values, selected, onSelect }) {
  return (
    <View style={styles.field}>
      <Text style={styles.fieldLabel}>{label}</Text>
      <View style={styles.typeGrid}>
        {values.map((value) => (
          <Pressable key={value} style={[styles.typeChip, selected === value && styles.typeChipSelected]} onPress={() => onSelect(value)}>
            <Text style={[styles.typeChipText, selected === value && styles.typeChipSelectedText]}>{value}</Text>
          </Pressable>
        ))}
      </View>
    </View>
  );
}

function recommend(context, clubs) {
  const rawDistance = distanceYards(context.ballLocation, context.target);
  const adjustedDistance = Math.max(1, rawDistance + rawDistance * liePenalty(context.lie) + context.wind * 1.1 + context.elevation / 3);
  return clubs
    .filter((club) => club.category !== "Putter")
    .map((club) => {
      const carry = numberValue(club.carryYards);
      const total = numberValue(club.totalYards);
      const gap = Math.abs(carry - adjustedDistance);
      const hazardRisk = context.hole.hazards.reduce((risk, hazard) => {
        const hazardDistance = distanceYards(context.ballLocation, hazard.coordinate);
        const inWindow = hazardDistance >= carry - numberValue(club.shortMissYards) && hazardDistance <= total + numberValue(club.longMissYards);
        const kindWeight = hazard.kind === "Water" || hazard.kind === "OB" ? 1 : hazard.kind === "Trees" ? 0.75 : 0.55;
        return risk + (inWindow ? kindWeight : 0);
      }, 0);
      const dispersionRisk = Math.min(40, avgDispersion(club)) / 40;
      const distanceRisk = Math.min(1, gap / Math.max(1, adjustedDistance * 0.22));
      const safetyScore = Math.max(0, 100 - hazardRisk * 42 - dispersionRisk * 28 - distanceRisk * 30);
      return { ...club, adjustedDistance, distanceGap: gap, safetyScore, confidence: Math.max(0.05, Math.min(0.98, safetyScore / 100)) };
    })
    .sort((a, b) => b.safetyScore - a.safetyScore || a.distanceGap - b.distanceGap);
}

function categoryForType(type) {
  if (type === "Driver") return "Driver";
  if (type.includes("Wood")) return "Wood";
  if (type.includes("Hybrid")) return "Hybrid";
  if (type.includes("Iron")) return "Iron";
  if (type === "Putter") return "Putter";
  return "Wedge";
}

function defaultCarry(type) {
  return {
    Driver: 245,
    "2 Wood": 232,
    "3 Wood": 218,
    "4 Wood": 210,
    "5 Wood": 202,
    "7 Wood": 190,
    "9 Wood": 180,
    "2 Hybrid": 205,
    "3 Hybrid": 195,
    "4 Hybrid": 185,
    "5 Hybrid": 175,
    "6 Hybrid": 165,
    "1 Iron": 205,
    "2 Iron": 195,
    "3 Iron": 185,
    "4 Iron": 175,
    "5 Iron": 165,
    "6 Iron": 155,
    "7 Iron": 145,
    "8 Iron": 135,
    "9 Iron": 125,
    "Pitching Wedge": 115,
    "Gap Wedge": 100,
    "Sand Wedge": 85,
    "Lob Wedge": 65,
    Chipper: 45,
    Putter: 10,
  }[type] || 145;
}

function defaultLoft(type) {
  return {
    Driver: 10.5,
    "3 Wood": 15,
    "5 Wood": 19,
    "7 Wood": 21,
    "4 Hybrid": 22,
    "5 Iron": 27,
    "6 Iron": 31,
    "7 Iron": 35,
    "8 Iron": 39,
    "9 Iron": 43,
    "Pitching Wedge": 46,
    "Gap Wedge": 50,
    "Sand Wedge": 56,
    "Lob Wedge": 60,
  }[type] || "";
}

function distanceYards(a, b) {
  const earthRadiusMeters = 6371000;
  const dLat = toRad(b.latitude - a.latitude);
  const dLon = toRad(b.longitude - a.longitude);
  const lat1 = toRad(a.latitude);
  const lat2 = toRad(b.latitude);
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return earthRadiusMeters * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h)) * 1.09361;
}

function bearingDegrees(a, b) {
  const lat1 = toRad(a.latitude);
  const lat2 = toRad(b.latitude);
  const dLon = toRad(b.longitude - a.longitude);
  const y = Math.sin(dLon) * Math.cos(lat2);
  const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
  return ((Math.atan2(y, x) * 180) / Math.PI + 360) % 360;
}

function destinationPoint(start, bearing, yards) {
  const radiusYards = 6371000 * 1.09361;
  const angularDistance = yards / radiusYards;
  const bearingRad = toRad(bearing);
  const lat1 = toRad(start.latitude);
  const lon1 = toRad(start.longitude);
  const lat2 = Math.asin(
    Math.sin(lat1) * Math.cos(angularDistance) +
      Math.cos(lat1) * Math.sin(angularDistance) * Math.cos(bearingRad)
  );
  const lon2 =
    lon1 +
    Math.atan2(
      Math.sin(bearingRad) * Math.sin(angularDistance) * Math.cos(lat1),
      Math.cos(angularDistance) - Math.sin(lat1) * Math.sin(lat2)
    );

  return {
    latitude: (lat2 * 180) / Math.PI,
    longitude: (((lon2 * 180) / Math.PI + 540) % 360) - 180,
  };
}

function offsetPoint(origin, forwardBearing, forwardYards, rightYards) {
  const forwardPoint = destinationPoint(origin, forwardBearing, forwardYards);
  return destinationPoint(forwardPoint, forwardBearing + 90, rightYards);
}

function dispersionPolygon(ballLocation, target, club) {
  const bearing = bearingDegrees(ballLocation, target);
  const left = numberValue(club.leftMissYards);
  const right = numberValue(club.rightMissYards);
  const short = numberValue(club.shortMissYards);
  const long = numberValue(club.longMissYards);
  const points = [];
  const steps = 28;

  for (let i = 0; i < steps; i += 1) {
    const angle = (2 * Math.PI * i) / steps;
    const forward = Math.sin(angle) >= 0 ? Math.sin(angle) * long : Math.sin(angle) * short;
    const lateral = Math.cos(angle) >= 0 ? Math.cos(angle) * right : Math.cos(angle) * left;
    points.push(offsetPoint(target, bearing, forward, lateral));
  }

  return points;
}

function toRad(value) {
  return (value * Math.PI) / 180;
}

function liePenalty(lie) {
  return { Tee: 0, Fairway: 0, "First cut": 0.04, Rough: 0.09, Sand: 0.16 }[lie] || 0;
}

function numberValue(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function avgDispersion(club) {
  return (numberValue(club.leftMissYards) + numberValue(club.rightMissYards) + numberValue(club.shortMissYards) + numberValue(club.longMissYards)) / 4;
}

function hazardColor(kind, opacity) {
  const color = kind === "Water" ? "35,125,230" : kind === "Bunker" ? "214,174,70" : kind === "OB" ? "230,70,70" : "35,150,70";
  return `rgba(${color},${opacity})`;
}

function shortControlLabel(value) {
  return value === "Green" ? "Appr" : value === "Fairway" ? "Tee" : value.replace(" Wedge", "W").replace(" Hybrid", "H").replace(" Iron", "i").replace(" Wood", "W");
}

function profileSubtitle(profile) {
  const parts = [];
  if (profile.handicap) parts.push(`HCP ${profile.handicap}`);
  if (profile.homeCourse) parts.push(profile.homeCourse);
  return parts.length ? parts.join(" - ") : "Handicap, home course, tees, and notes";
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: "#050706" },
  vignette: { ...StyleSheet.absoluteFillObject, backgroundColor: "rgba(0,0,0,0.08)" },
  overlay: { flex: 1 },
  topRow: { flexDirection: "row", justifyContent: "space-between", paddingHorizontal: 18, paddingTop: Platform.OS === "android" ? 28 : 8 },
  metricBubble: { backgroundColor: "rgba(0,0,0,0.86)", borderRadius: 28, paddingHorizontal: 17, paddingVertical: 9, minWidth: 98, alignItems: "center" },
  metricTitle: { color: "rgba(255,255,255,0.78)", fontSize: 10, fontWeight: "800" },
  metricValue: { color: "#fff", fontSize: 18, fontWeight: "900" },
  centerReadout: { position: "absolute", top: "21%", alignSelf: "center", alignItems: "center" },
  mainYardage: { color: "#fff", fontSize: 48, fontWeight: "800", textShadowColor: "#000", textShadowRadius: 5, textShadowOffset: { width: 0, height: 2 } },
  confidence: { color: "#60e980", fontSize: 18, fontWeight: "800", textShadowColor: "#000", textShadowRadius: 3 },
  badgeRow: { flexDirection: "row", gap: 8, marginTop: 7 },
  miniBadge: { color: "#fff", backgroundColor: "rgba(0,0,0,0.72)", borderRadius: 16, paddingHorizontal: 10, paddingVertical: 6, fontSize: 12, fontWeight: "800" },
  dragHint: { color: "rgba(255,255,255,0.82)", backgroundColor: "rgba(0,0,0,0.58)", borderRadius: 12, marginTop: 8, paddingHorizontal: 9, paddingVertical: 4, fontSize: 11, fontWeight: "800", overflow: "hidden" },
  sideArea: { position: "absolute", left: 18, right: 18, bottom: 64, flexDirection: "row", justifyContent: "space-between", alignItems: "flex-end" },
  leftRail: { width: 52, borderRadius: 28, backgroundColor: "rgba(0,0,0,0.86)", paddingVertical: 10, alignItems: "center", gap: 8 },
  railButton: { width: 42, height: 42, alignItems: "center", justifyContent: "center" },
  railText: { color: "#fff", fontSize: 11, fontWeight: "800" },
  rightRail: { alignItems: "center", gap: 12 },
  windPill: { width: 54, height: 54, borderRadius: 27, backgroundColor: "rgba(0,0,0,0.86)", alignItems: "center", justifyContent: "center" },
  windArrow: { color: "#fff", fontSize: 14, fontWeight: "900" },
  windText: { color: "#fff", fontSize: 11, fontWeight: "900" },
  liveText: { color: "#fff", fontSize: 8, fontWeight: "700" },
  segment: { overflow: "hidden", borderRadius: 24, backgroundColor: "rgba(0,0,0,0.86)" },
  segmentItem: { width: 48, height: 39, alignItems: "center", justifyContent: "center", borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: "rgba(255,255,255,0.18)" },
  segmentCompact: { height: 35 },
  segmentSelected: { backgroundColor: "rgba(255,255,255,0.92)" },
  segmentText: { color: "#fff", fontSize: 11, fontWeight: "900" },
  segmentSelectedText: { color: "#000" },
  roundButton: { width: 50, height: 50, borderRadius: 25, backgroundColor: "rgba(0,0,0,0.86)", alignItems: "center", justifyContent: "center" },
  roundButtonText: { color: "#fff", fontSize: 11, fontWeight: "900" },
  bottomBar: { position: "absolute", left: 72, right: 72, bottom: 18, borderRadius: 28, backgroundColor: "rgba(0,0,0,0.86)", flexDirection: "row", alignItems: "center", justifyContent: "space-between", paddingHorizontal: 14, paddingVertical: 8 },
  chevron: { color: "#fff", fontSize: 32, fontWeight: "600" },
  holeLabel: { alignItems: "center" },
  holeTitle: { color: "#fff", fontSize: 12, fontWeight: "900" },
  holeSub: { color: "#fff", fontSize: 13, fontWeight: "800" },
  ballMarker: { width: 22, height: 22, borderRadius: 11, backgroundColor: "#000", borderWidth: 3, borderColor: "#fff", alignItems: "center", justifyContent: "center" },
  ballDot: { width: 6, height: 6, borderRadius: 3, backgroundColor: "#fff" },
  targetMarker: { width: 58, height: 58, borderRadius: 29, borderWidth: 2, borderColor: "rgba(255,255,255,0.95)", alignItems: "center", justifyContent: "center" },
  greenMarker: { width: 86, height: 86, borderRadius: 43 },
  targetDot: { width: 22, height: 22, borderRadius: 11, backgroundColor: "#000", alignItems: "center", justifyContent: "center" },
  targetIcon: { color: "#fff", fontSize: 12, fontWeight: "900" },
  modal: { flex: 1, backgroundColor: "#101211" },
  modalHeader: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", paddingHorizontal: 18, paddingVertical: 14, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: "#2a2d2b" },
  modalTitle: { color: "#fff", fontSize: 20, fontWeight: "900" },
  doneText: { color: "#70d489", fontSize: 16, fontWeight: "800" },
  modalContent: { padding: 16, gap: 12 },
  profileCard: { backgroundColor: "#1b1f1c", borderRadius: 8, padding: 16 },
  cardTitle: { color: "#fff", fontSize: 18, fontWeight: "900" },
  cardSub: { color: "#aab0aa", marginTop: 4 },
  addButton: { backgroundColor: "#e9f2e9", borderRadius: 8, padding: 14, alignItems: "center" },
  addButtonText: { color: "#101211", fontSize: 15, fontWeight: "900" },
  typeGrid: { flexDirection: "row", flexWrap: "wrap", gap: 8 },
  typeChip: { backgroundColor: "#242a25", borderRadius: 16, paddingHorizontal: 11, paddingVertical: 8 },
  typeChipSelected: { backgroundColor: "#e9f2e9" },
  typeChipText: { color: "#fff", fontSize: 12, fontWeight: "800" },
  typeChipSelectedText: { color: "#101211" },
  clubRow: { backgroundColor: "#1b1f1c", borderRadius: 8, padding: 14, flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  clubName: { color: "#fff", fontSize: 17, fontWeight: "900" },
  clubMeta: { color: "#aab0aa", fontSize: 12, marginTop: 3 },
  clubNumbers: { alignItems: "flex-end" },
  clubCarry: { color: "#fff", fontSize: 14, fontWeight: "800" },
  field: { gap: 7 },
  fieldLabel: { color: "#cbd2cb", fontSize: 13, fontWeight: "800" },
  input: { backgroundColor: "#1b1f1c", color: "#fff", borderRadius: 8, padding: 13, fontSize: 16 },
  textArea: { minHeight: 100, textAlignVertical: "top" },
});
